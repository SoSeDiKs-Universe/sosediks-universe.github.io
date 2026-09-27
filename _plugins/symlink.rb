require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'cgi'

module Jekyll
  module McImages
    WIKI_HOST  = 'https://minecraft.wiki'
    USER_AGENT = 'Jekyll-McImages/1.0'
    CACHE_PATH = File.join('.jekyll-cache', 'mc-images.json')
    CACHE_TTL  = 7 * 24 * 60 * 60   # 7 days

    @@urls      = {}   # symlink key => direct URL (runtime, per process)
    @@file_urls = {}   # filename    => direct URL (persisted across runs)
    @@failed    = []
    @@resolved  = false

    def self.resolve!(mappings)
      return if @@resolved
      @@resolved = true

      load_cache

      by_filename = Hash.new { |h, k| h[k] = [] }
      pending     = []

      mappings.each do |key, data|
        next unless data[:image]
        filename = data[:image].split('?').first.split('/').last
        next unless filename && !filename.empty?

        by_filename[filename] << key

        if @@file_urls.key?(filename)
          @@urls[key] = @@file_urls[filename]
        else
          pending << filename
        end
      end

      pending.uniq!

      if pending.empty?
        Jekyll.logger.info "McImages",
          "All #{by_filename.size} image URLs loaded from cache (0 API calls)"
      else
        Jekyll.logger.info "McImages",
          "Resolving #{pending.size} new image URLs from API…"
        batches = pending.each_slice(50).to_a
        batches.each_with_index do |batch, i|
          Jekyll.logger.info "McImages", "Batch #{i + 1}/#{batches.size} (#{batch.size} files)"
          process_batch(batch, by_filename)
          sleep 1.0 if i < batches.size - 1
        end
        save_cache
      end
    end

    def self.process_batch(batch, by_filename)
      data = fetch_batch(batch)
      unless data
        batch.each { |f| by_filename[f].each { |k| record_failure(k, f) } }
        return
      end

      url_by_title = {}
      (data.dig('query', 'pages') || []).each do |page|
        next unless page['imageinfo'] && page['imageinfo'][0]
        url_by_title[page['title']] = page['imageinfo'][0]['url']
      end

      (data.dig('query', 'redirects') || []).each do |r|
        url_by_title[r['from']] = url_by_title[r['to']] if url_by_title.key?(r['to'])
      end
      (data.dig('query', 'normalized') || []).each do |n|
        url_by_title[n['from']] = url_by_title[n['to']] if url_by_title.key?(n['to'])
      end

      batch.each do |filename|
        url = url_by_title["File:#{filename}"]
        if url
          @@file_urls[filename] = url
          by_filename[filename].each { |k| @@urls[k] = url }
        else
          by_filename[filename].each { |k| record_failure(k, filename) }
        end
      end
    end

    def self.fetch_batch(filenames)
      titles = filenames.map { |f| "File:#{f}" }.join('|')
      uri = URI("#{WIKI_HOST}/api.php")
      uri.query = URI.encode_www_form(
        action:        'query',
        titles:        titles,
        prop:          'imageinfo',
        iiprop:        'url',
        redirects:     '1',
        format:        'json',
        formatversion: '2'
      )

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true
      http.open_timeout = 15
      http.read_timeout = 30

      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = USER_AGENT
      req['Accept']     = 'application/json'

      res = http.request(req)

      unless res.is_a?(Net::HTTPSuccess)
        Jekyll.logger.warn "McImages",
          "HTTP #{res.code} from API. First 200 bytes: #{res.body.to_s[0, 200].inspect}"
        return nil
      end

      begin
        JSON.parse(res.body)
      rescue JSON::ParserError => e
        Jekyll.logger.warn "McImages",
          "Non-JSON response (#{e.message}). First 200 bytes: #{res.body.to_s[0, 200].inspect}"
        nil
      end
    end

    def self.record_failure(key, filename)
      fallback = "#{WIKI_HOST}/wiki/Special:FilePath/#{filename}"
      @@urls[key] ||= fallback
      @@failed << key unless @@failed.include?(key)
      Jekyll.logger.warn "McImages",
        "No API match for '#{filename}' (used by #{key}); using Special:FilePath fallback"
    end

    def self.load_cache
      return unless File.exist?(CACHE_PATH)
      raw = begin
        JSON.parse(File.read(CACHE_PATH))
      rescue StandardError
        nil
      end
      return unless raw

      if raw['timestamp'] && (Time.now.to_i - raw['timestamp'].to_i) < CACHE_TTL
        @@file_urls = raw['urls'] || {}
        Jekyll.logger.info "McImages",
          "Loaded #{@@file_urls.size} cached URLs from #{CACHE_PATH}"
      else
        Jekyll.logger.info "McImages", "Cache at #{CACHE_PATH} is stale; refetching"
      end
    end

    def self.save_cache
      FileUtils.mkdir_p(File.dirname(CACHE_PATH))
      File.write(CACHE_PATH, JSON.pretty_generate({
        timestamp: Time.now.to_i,
        urls:      @@file_urls
      }))
      Jekyll.logger.info "McImages",
        "Saved #{@@file_urls.size} URLs to #{CACHE_PATH}"
    end

    def self.url_for(key)
      @@urls[key]
    end

    def self.failed
      @@failed
    end
  end
end

module Jekyll
  class SymlinkTag < Liquid::Tag

    # Game terms quoted as «Name» and colored by their kind
    KIND_CLASSES = {
      enchantment: 'mc-aqua',
      curse: 'mc-red',
      beneficial_effect: 'mc-blue',
      neutral_effect: 'mc-yellow',
      harmful_effect: 'mc-red'
    }

    # Variant sets, in creative inventory order
    DYE_COLORS = %w[white light_gray gray black brown red orange yellow lime green cyan light_blue blue purple magenta pink]
    WOOD_TYPES = %w[oak spruce birch jungle acacia dark_oak mangrove cherry pale_oak bamboo crimson warped]
    BOAT_WOOD_TYPES = %w[oak spruce birch jungle acacia dark_oak mangrove cherry pale_oak]
    MOB_CLIMATES = %w[temperate warm cold]
    # Tipped arrows that look distinct (without the plain ones), in creative inventory order
    TIPPED_ARROW_EFFECTS = %w[
      water night_vision invisibility leaping fire_resistance swiftness slowness turtle_master water_breathing healing
      harming poison regeneration strength weakness luck slow_falling wind_charged weaving oozing infested
    ]
    # All slabs/stairs from the game's lang file, without waxed copper (same look) and the unobtainable petrified oak slab
    SLABS = %w[
      acacia_slab andesite_slab bamboo_mosaic_slab bamboo_slab birch_slab black_concrete_slab black_wool_slab
      blackstone_slab blue_concrete_slab blue_wool_slab brick_slab brown_concrete_slab brown_wool_slab cherry_slab
      cinnabar_brick_slab cinnabar_slab cobbled_deepslate_slab cobblestone_slab crimson_slab cut_copper_slab
      cut_red_sandstone_slab cut_sandstone_slab cyan_concrete_slab cyan_wool_slab dark_oak_slab dark_prismarine_slab
      deepslate_brick_slab deepslate_tile_slab diorite_slab end_stone_brick_slab exposed_cut_copper_slab
      granite_slab gray_concrete_slab gray_wool_slab green_concrete_slab green_wool_slab jungle_slab
      light_blue_concrete_slab light_blue_wool_slab light_gray_concrete_slab light_gray_wool_slab lime_concrete_slab
      lime_wool_slab magenta_concrete_slab magenta_wool_slab mangrove_slab mossy_cobblestone_slab
      mossy_stone_brick_slab mud_brick_slab nether_brick_slab oak_slab orange_concrete_slab orange_wool_slab
      oxidized_cut_copper_slab pale_oak_slab pink_concrete_slab pink_wool_slab polished_andesite_slab
      polished_blackstone_brick_slab polished_blackstone_slab polished_cinnabar_slab polished_deepslate_slab
      polished_diorite_slab polished_granite_slab polished_sulfur_slab polished_tuff_slab poplar_slab
      prismarine_brick_slab prismarine_slab purple_concrete_slab purple_wool_slab purpur_slab quartz_slab
      red_concrete_slab red_nether_brick_slab red_sandstone_slab red_wool_slab resin_brick_slab sandstone_slab
      smooth_quartz_slab smooth_red_sandstone_slab smooth_sandstone_slab smooth_stone_slab spruce_slab
      stone_brick_slab stone_slab sulfur_brick_slab sulfur_slab tuff_brick_slab tuff_slab warped_slab
      weathered_cut_copper_slab white_concrete_slab white_wool_slab yellow_concrete_slab yellow_wool_slab
    ]
    STAIRS = %w[
      acacia_stairs andesite_stairs bamboo_mosaic_stairs bamboo_stairs birch_stairs black_concrete_stairs
      black_wool_stairs blackstone_stairs blue_concrete_stairs blue_wool_stairs brick_stairs brown_concrete_stairs
      brown_wool_stairs cherry_stairs cinnabar_brick_stairs cinnabar_stairs cobbled_deepslate_stairs
      cobblestone_stairs crimson_stairs cut_copper_stairs cyan_concrete_stairs cyan_wool_stairs dark_oak_stairs
      dark_prismarine_stairs deepslate_brick_stairs deepslate_tile_stairs diorite_stairs end_stone_brick_stairs
      exposed_cut_copper_stairs granite_stairs gray_concrete_stairs gray_wool_stairs green_concrete_stairs
      green_wool_stairs jungle_stairs light_blue_concrete_stairs light_blue_wool_stairs light_gray_concrete_stairs
      light_gray_wool_stairs lime_concrete_stairs lime_wool_stairs magenta_concrete_stairs magenta_wool_stairs
      mangrove_stairs mossy_cobblestone_stairs mossy_stone_brick_stairs mud_brick_stairs nether_brick_stairs
      oak_stairs orange_concrete_stairs orange_wool_stairs oxidized_cut_copper_stairs pale_oak_stairs
      pink_concrete_stairs pink_wool_stairs polished_andesite_stairs polished_blackstone_brick_stairs
      polished_blackstone_stairs polished_cinnabar_stairs polished_deepslate_stairs polished_diorite_stairs
      polished_granite_stairs polished_sulfur_stairs polished_tuff_stairs poplar_stairs prismarine_brick_stairs
      prismarine_stairs purple_concrete_stairs purple_wool_stairs purpur_stairs quartz_stairs red_concrete_stairs
      red_nether_brick_stairs red_sandstone_stairs red_wool_stairs resin_brick_stairs sandstone_stairs
      smooth_quartz_stairs smooth_red_sandstone_stairs smooth_sandstone_stairs spruce_stairs stone_brick_stairs
      stone_stairs sulfur_brick_stairs sulfur_stairs tuff_brick_stairs tuff_stairs warped_stairs
      weathered_cut_copper_stairs white_concrete_stairs white_wool_stairs yellow_concrete_stairs yellow_wool_stairs
    ]

    def self.wiki_file(name)
      "https://minecraft.wiki/wiki/Special:FilePath/#{name}"
    end

    # oak_door -> Oak_Door
    def self.file_case(id)
      id.split('_').map(&:capitalize).join('_')
    end

    MAPPINGS = {
      # Groups: a generic mention whose icon cycles through all members
      'glass_blocks' => { group: ['glass', *DYE_COLORS.map { |c| "#{c}_stained_glass" }] },
      'glass_panes' => { group: ['glass_pane', *DYE_COLORS.map { |c| "#{c}_stained_glass_pane" }] },
      'rails' => { group: %w[rail powered_rail detector_rail activator_rail] },
      'doors' => { group: [*WOOD_TYPES.map { |w| "#{w}_door" }, 'iron_door', 'copper_door'] },
      'trapdoors' => { group: [*WOOD_TYPES.map { |w| "#{w}_trapdoor" }, 'iron_trapdoor', 'copper_trapdoor'] },
      'fences' => { group: [*WOOD_TYPES.map { |w| "#{w}_fence" }, 'nether_brick_fence'] },
      'fence_gates' => { group: WOOD_TYPES.map { |w| "#{w}_fence_gate" } },
      'buttons' => { group: [*WOOD_TYPES.map { |w| "#{w}_button" }, 'stone_button', 'polished_blackstone_button'] },
      'pressure_plates' => { group: [*WOOD_TYPES.map { |w| "#{w}_pressure_plate" }, 'stone_pressure_plate', 'polished_blackstone_pressure_plate', 'light_weighted_pressure_plate', 'heavy_weighted_pressure_plate'] },
      'signs' => { group: WOOD_TYPES.map { |w| "#{w}_sign" } },
      'leaves' => { group: %w[oak spruce birch jungle acacia dark_oak mangrove cherry pale_oak azalea flowering_azalea].map { |w| "#{w}_leaves" } },
      'boats' => { group: [*BOAT_WOOD_TYPES.map { |w| "#{w}_boat_entity" }, 'bamboo_raft_entity'] },
      'beds' => { group: DYE_COLORS.map { |c| "#{c}_bed" } },
      'carpets' => { group: DYE_COLORS.map { |c| "#{c}_carpet" } },
      'wool' => { group: DYE_COLORS.map { |c| "#{c}_wool" } },
      'candles' => { group: ['candle', *DYE_COLORS.map { |c| "#{c}_candle" }] },
      'slabs' => { group: SLABS },
      'stairs' => { group: STAIRS },
      'torches' => { group: %w[torch soul_torch copper_torch redstone_torch] },
      'campfires' => { group: %w[campfire soul_campfire] },
      # Bushes that prick (the server's own Sweet Berry Pips Bush has no texture on the wiki yet)
      'bushes' => { group: %w[sweet_berry_bush] },
      'coal_ores' => { group: %w[coal_ore deepslate_coal_ore] },
      'fish' => { group: %w[cod_entity salmon_fish pufferfish_entity tropical_fish_entity] },
      'arrows' => { group: ['arrow', 'spectral_arrow', *TIPPED_ARROW_EFFECTS.map { |e| "#{e}_tipped_arrow" }] },
      # Entities
      'wandering_trader' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/EntitySprite_wandering-trader.png',
        url: '/wiki/entity/wandering_trader'
      },
      'player' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/EntitySprite_steve.png',
        url: '/wiki/entity/player'
      },
      'llama' => { group: %w[creamy white brown gray].map { |c| "#{c}_llama" } },
      'sheep' => { group: DYE_COLORS.map { |c| "#{c}_sheep" } },
      'rainbow_sheep' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Jeb_Sheep_JE5.webp',
        text_class: 'mc-jeb'
      },
      'chicken' => { group: MOB_CLIMATES.map { |c| "#{c}_chicken" } },
      'baby_chicken' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Baby_Chicken.png'
      },
      'horse' => { group: %w[white creamy chestnut brown black gray dark_brown].map { |c| "#{c}_horse" } },
      'mule' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Mule.png'
      },
      'zombie_horse' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Zombie_Horse.png'
      },
      'skeleton_horse' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Skeleton_Horse.png'
      },
      'frog' => { group: MOB_CLIMATES.map { |c| "#{c}_frog" } },
      'squid' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Squid.gif'
      },
      'glow_squid' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Glow_Squid.gif'
      },
      'allay' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Allay.gif'
      },
      'vex' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Vex.gif'
      },
      'strider' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Strider.gif'
      },
      'nautilus' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Nautilus_Breathe_JE1_BE2.gif'
      },
      'zombie_nautilus' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Zombie_Nautilus_Breathe_JE1_BE2.gif'
      },
      'pillager' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Pillager.png'
      },
      'polar_bear' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Polar_Bear.png'
      },
      'salmon_fish' => {
        name_key: 'entity.minecraft.salmon',
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Salmon.gif'
      },
      'ocelot' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Ocelot.png'
      },
      'phantom' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Phantom.gif'
      },
      'parrot' => { group: %w[red blue green cyan gray].map { |c| "#{c}_parrot" } },
      'wolf' => { group: %w[pale woods ashen black chestnut rusty spotted snowy striped].map { |c| "#{c}_wolf" } },
      'pig' => { group: MOB_CLIMATES.map { |c| "#{c}_pig" } },
      'cow' => { group: MOB_CLIMATES.map { |c| "#{c}_cow" } },
      'bee' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Bee.gif'
      },
      'silverfish' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Silverfish.gif'
      },
      'endermite' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Endermite.gif'
      },
      'ghast' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Ghast.gif'
      },
      'evoker' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Evoker.png'
      },
      'creeper' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Creeper.png'
      },
      'enderman' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Enderman.png'
      },
      'skeleton' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Skeleton.png'
      },
      'stray' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Stray.png'
      },
      'bogged' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Bogged.png'
      },
      'parched' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Parched.png'
      },
      'wither_skeleton' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Wither_Skeleton.png'
      },
      'slime' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Slime.png'
      },
      'magma_cube' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Magma_Cube.png'
      },
      'armor_stand_entity' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Armor_Stand.png'
      },
      'oak_boat_entity' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Oak_Boat.png'
      },
      'minecart_entity' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Minecart.png'
      },
      'tnt_minecart_entity' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Minecart_with_TNT.png'
      },
      'shulker_open' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Shulker.png'
      },
      'snowman_sheared' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Sheared_Snow_Golem.png'
      },
      'fox' => { group: %w[red_fox snow_fox] },
      'bat' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Bat.png'
      },
      # Items
      'bucket' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Bucket.png'
      },
      'water_bucket' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Water_Bucket.png'
      },
      'lava_bucket' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Lava_Bucket.png'
      },
      'blaze_powder' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Blaze_Powder.png'
      },
      'blaze_rod' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Blaze_Rod.png'
      },
      'fire_charge' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Fire_Charge.png'
      },
      'flint_and_steel' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Flint_and_Steel.png'
      },
      'shears' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Shears.png'
      },
      'elytra' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Elytra.png'
      },
      'wooden_shovel' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Wooden_Shovel.png'
      },
      'wooden_hoe' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Wooden_Hoe.png'
      },
      'book' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Book.png'
      },
      'magma_cream' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Magma_Cream.png'
      },
      'torch' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Torch.png'
      },
      'soul_torch' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Soul_Torch.png'
      },
      'copper_torch' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Copper_Torch.png'
      },
      'saddle' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Saddle.png'
      },
      'feather' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Feather.png'
      },
      'slime_ball' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Slimeball.png'
      },
      'rotten_flesh' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Rotten_Flesh.png'
      },
      'bone_meal' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Bone_Meal.png'
      },
      'crossbow' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Crossbow.png'
      },
      'glass_bottle' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Glass_Bottle.png'
      },
      'potion' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Water_Bottle.png'
      },
      'water_potion' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Water_Bottle.png'
      },
      'splash_water_potion' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Splash_Water_Bottle.png'
      },
      'lingering_water_potion' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Lingering_Water_Bottle.png'
      },
      'honey_bottle' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Honey_Bottle.png'
      },
      'leather_helmet' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Leather_Cap.png'
      },
      'leather_chestplate' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Leather_Tunic.png'
      },
      'item_frame' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Item_Frame.png'
      },
      'painting' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Painting.png'
      },
      'paper' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Paper.png'
      },
      'writable_book' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Book_and_Quill.png'
      },
      'enchanted_book' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Enchanted_Book.gif'
      },
      'clock' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Clock.gif'
      },
      'compass' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Compass.gif'
      },
      'poisonous_potato' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Poisonous_Potato.png'
      },
      'arrow' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Arrow.png'
      },
      'snowball' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Snowball.png'
      },
      'egg' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Egg.png'
      },
      'spyglass' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Spyglass.png'
      },
      'red_mushroom' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Red_Mushroom.png'
      },
      'brown_mushroom' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Brown_Mushroom.png'
      },
      'trident' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Trident.png'
      },
      'piston' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Piston_(U)_JE3.gif'
      },
      'sticky_piston' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Sticky_Piston_(U)_JE3.gif'
      },
      'observer' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Observer.png'
      },
      'grass_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Grass_Block.png'
      },
      'podzol' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Podzol.png'
      },
      'gravel' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Gravel.png'
      },
      'sand' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Sand.png'
      },
      'sandstone' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Sandstone.png'
      },
      'red_sand' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Red_Sand.png'
      },
      'red_sandstone' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Red_Sandstone.png'
      },
      'water_cauldron' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Water_Cauldron.png'
      },
      'cracked_stone_bricks' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Cracked_Stone_Bricks.png'
      },
      'glass' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Glass.png'
      },
      'lava' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Lava.gif'
      },
      'water' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Water.png'
      },
      'campfire' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Campfire.png'
      },
      'campfire_block_unlit' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Unlit_Campfire.png'
      },
      'cactus' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Cactus.png'
      },
      'sweet_berries' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Sweet_Berry_Bush_Age_3.png'
      },
      'oak_door' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Door.png'
      },
      'oak_trapdoor' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Trapdoor.png'
      },
      'oak_fence' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Fence.png'
      },
      'oak_fence_gate' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Fence_Gate.png'
      },
      'oak_button' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Button.png'
      },
      'oak_sign' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Sign.png'
      },
      'oak_pressure_plate' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Pressure_Plate.png'
      },
      'oak_slab' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Slab.png'
      },
      'oak_stairs' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Stairs.png'
      },
      'oak_leaves' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Oak_Leaves.png'
      },
      'magma_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Magma_Block.gif'
      },
      'crying_obsidian' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Crying_Obsidian.png'
      },
      'chest' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Chest.png'
      },
      'note_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Note_Block.png'
      },
      'ice' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Ice.png'
      },
      'glass_pane' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Glass_Pane.png'
      },
      'packed_ice' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Packed_Ice.png'
      },
      'blue_ice' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Blue_Ice.png'
      },
      'snow_layer_1' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Snow.png'
      },
      'snow_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Snow_Block.png'
      },
      'powder_snow' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Powder_Snow.png'
      },
      'hay_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Hay_Bale.png'
      },
      'slime_block' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Slime_Block.png'
      },
      'melon' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Melon.png'
      },
      'pumpkin' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Pumpkin.png'
      },
      'carved_pumpkin' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Carved_Pumpkin.png'
      },
      'jack_o_lantern' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Jack_o\'Lantern.png'
      },
      'cobweb' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Cobweb.png'
      },
      'scaffolding' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Scaffolding.png'
      },
      'tnt' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_TNT.png'
      },
      'candle' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Candle.png'
      },
      'candle_cake' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Cake_with_Candle.png'
      },
      'coal_ore' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Coal_Ore.png'
      },
      'stonecutter' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Stonecutter.gif'
      },
      'fire' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Fire.gif'
      },
      'dirt' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Dirt.png'
      },
      'coarse_dirt' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Coarse_Dirt.png'
      },
      'dirt_path' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Dirt_Path.png'
      },
      'farmland' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Farmland.png'
      },
      'magenta_glazed_terracotta' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Magenta_Glazed_Terracotta.png'
      },
      'rail' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Rail.png'
      },
      'detector_rail' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Detector_Rail.png'
      },
      'wither_rose' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Wither_Rose.png'
      },
      'wither_skeleton_skull' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Wither_Skeleton_Skull.png'
      },
      'white_carpet' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_White_Carpet.png'
      },
      'red_bed' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Red_Bed.png'
      },
      'bee_nest' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Bee_Nest.png'
      },
      'flower_pot' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Flower_Pot.png'
      },
      'pink_petals' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Pink_Petals.png'
      },
      'wildflowers' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Invicon_Wildflowers.png'
      },
      # Potion effects
      'fire_resistance' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Fire_Resistance.png',
        kind: :beneficial_effect
      },
      'blindness' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Blindness.png',
        kind: :harmful_effect
      },
      'slowness' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Slowness.png',
        kind: :harmful_effect
      },
      'poison' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Poison.png',
        kind: :harmful_effect
      },
      'weakness' => {
        image: 'https://minecraft.wiki/wiki/Special:FilePath/Weakness.png',
        kind: :harmful_effect
      },
      # Enchantments
      'fire_aspect' => { kind: :enchantment },
      'flame' => { kind: :enchantment },
      'frost_walker' => { kind: :enchantment },
      'impaling' => { kind: :enchantment },
      'multishot' => { kind: :enchantment },
      'silk_touch' => { kind: :enchantment },
      'smite' => { kind: :enchantment },
      'binding_curse' => { kind: :curse },
      'vanishing_curse' => { kind: :curse },
      # Internal items
      'gloves' => {
        emoji: '🧤',
        url: '/wiki/mechanics/gloves'
      },
      # Mechanics
      'fragile_blocks' => {
        emoji: '🪟',
        url: '/wiki/mechanics/fragile_blocks'
      },
      'hot_items' => {
        emoji: '🔥',
        url: '/wiki/mechanics/hot_items'
      },
      'soft_blocks' => {
        emoji: '🌾',
        url: '/wiki/mechanics/soft_blocks'
      },
      # Internal
      'block_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/block_changes'
      },
      'entity_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/entity_changes'
      },
      'credits' => {
        emoji: '⚙️',
        url: '/wiki/misc/credits'
      },
      'item_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/item_changes'
      },
      'misc_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/misc_changes'
      },
      'player_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/player_changes'
      },
      'vehicle_changes' => {
        emoji: '⚙️',
        url: '/wiki/misc/vehicle_changes'
      },
      # Credits
      'pixel-twemoji' => {
        text: 'Pixel perfect Twemoji',
        github: 'https://github.com/AmberWat/PixelTwemojiMC-9'
      },
      'realm-rpg-fallen-adventurers' => {
        text: 'Realm RPG: Fallen Adventurers',
        modrinth: 'https://modrinth.com/mod/realm-rpg-fallen-adventurers'
      },
      'totemic' => {
        text: 'Totemic',
        modrinth: 'https://modrinth.com/mod/fenns_totemic'
      },
      'requiem' => {
        text: 'Requiem',
        modrinth: 'https://modrinth.com/mod/requiem'
      },
      'consecration' => {
        text: 'Consecration',
        modrinth: 'https://modrinth.com/mod/consecration'
      },
      'glide-away' => {
        text: 'Glide Away!',
        modrinth: 'https://modrinth.com/mod/glide-away'
      },
      'trick-or-treat' => {
        text: 'Trick or Treat',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/trick-or-treat'
      },
      'berry-good' => {
        text: 'Berry Good',
        modrinth: 'https://modrinth.com/mod/berry-good'
      },
      'urkaz-moon-tools' => {
        text: 'Urkaz Moon Tools',
        modrinth: 'https://modrinth.com/mod/urkaz-moon-tools'
      },
      'cactus-juice' => {
        text: 'Maht\'s Cactus Juice',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/cactus'
      },
      'immersive-armor-hud' => {
        text: 'Immersive Armor HUD',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/immersive-armor-hud'
      },
      'big-brain' => {
        text: 'Big Brain',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/big-brain'
      },
      'sneaky-curses' => {
        text: 'Sneaky Curses',
        modrinth: 'https://modrinth.com/mod/sneaky-curses'
      },
      'mobs-attempt-parkour' => {
        text: 'Mobs Attempt Parkour',
        curseforge: 'https://modrinth.com/mod/mobs-attempt-parkour'
      },
      'blazeandcaves-advancements-pack' => {
        text: 'BlazeandCave\'s Advancements Pack',
        modrinth: 'https://modrinth.com/datapack/blazeandcaves-advancements-pack'
      },
      'bacap-enhanced-discoveries' => {
        text: 'BlazeandCave\'s Advancement Pack Enhanced Discoveries',
        modrinth: 'https://modrinth.com/datapack/bacap-enhanced-discoveries'
      },
      'bacap-torture-edition' => {
        text: 'BlazeandCave\'s Advancement Pack Torture Edition',
        pmc: 'https://www.planetminecraft.com/data-pack/bacap-torture-edition'
      },
      'tiny-skeletons' => {
        text: 'Tiny Skeletons',
        modrinth: 'https://modrinth.com/mod/tiny-skeletons'
      },
      'bucketem' => {
        text: 'Bucket\'Em',
        modrinth: 'https://modrinth.com/mod/bucketem'
      },
      'bucket-of-frog' => {
        text: 'Bucket of Frog',
        modrinth: 'https://modrinth.com/mod/bucket-of-frog'
      },
      'bucket-of-nautilus' => {
        text: 'Bucket of Nautilus',
        modrinth: 'https://modrinth.com/mod/bucket-of-nautilus'
      },
      'kfa' => {
        text: 'Kentucky Fried Axolotls',
        modrinth: 'https://modrinth.com/mod/kfa'
      },
      'axolotl-bucket-fix' => {
        text: 'Axolotl Bucket Fix',
        modrinth: 'https://modrinth.com/mod/axolotl-bucket-fix'
      },
      'chainmail-bucket' => {
        text: 'Chainmail Bucket',
        modrinth: 'https://modrinth.com/mod/chainmail-bucket'
      },
      'invariable-paintings' => {
        text: 'Invariable Paintings',
        modrinth: 'https://modrinth.com/mod/invariable-paintings'
      },
      'dark-paintings' => {
        text: 'Dark Paintings',
        modrinth: 'https://modrinth.com/mod/dark-paintings'
      },
      'portfolio' => {
        text: 'Portfolio',
        modrinth: 'https://modrinth.com/datapack/portfolio'
      },
      'texels-paintings' => {
        text: 'Texels Paintings',
        modrinth: 'https://modrinth.com/mod/texels-paintings'
      },
      'macaws-paintings' => {
        text: 'Macaw\'s Paintings',
        modrinth: 'https://modrinth.com/mod/macaws-paintings'
      },
      'more-additional-paintings' => {
        text: 'More Additional Paintings',
        modrinth: 'https://modrinth.com/mod/more-additional-paintings'
      },
      'carbasa' => {
        text: 'Carbasa',
        modrinth: 'https://modrinth.com/mod/carbasa'
      },
      'leons-spooky-paintings' => {
        text: 'Leon\'s Spooky Paintings',
        modrinth: 'https://modrinth.com/mod/leons-spooky-paintings'
      },
      'leons-dungeons-paintings' => {
        text: 'Leon\'s Dungeons Paintings',
        modrinth: 'https://modrinth.com/mod/leons-dungeons-paintings'
      },
      'wooden-buckets' => {
        text: 'Wooden Buckets',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/wooden-buckets'
      },
      'ceramic-bucket' => {
        text: 'Ceramic Bucket',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/ceramic-bucket'
      },
      'early-game-buckets' => {
        text: 'Early-Game Buckets',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/early-game-buckets'
      },
      'gallery' => {
        text: 'Gallery',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/gallery'
      },
      'fabrication' => {
        text: 'Fabrication',
        curseforge: 'https://www.curseforge.com/minecraft/mc-mods/fabrication'
      }
    }

    # Group members; entries defined above take precedence
    def self.add_image(id, file)
      MAPPINGS[id] ||= { image: wiki_file(file) }
    end

    DYE_COLORS.each do |color|
      name = file_case(color)
      add_image("#{color}_stained_glass", "Invicon_#{name}_Stained_Glass.png")
      add_image("#{color}_stained_glass_pane", "Invicon_#{name}_Stained_Glass_Pane.png")
      add_image("#{color}_bed", "Invicon_#{name}_Bed.png")
      add_image("#{color}_carpet", "Invicon_#{name}_Carpet.png")
      add_image("#{color}_wool", "Invicon_#{name}_Wool.png")
      add_image("#{color}_candle", "Invicon_#{name}_Candle.png")
      add_image("#{color}_sheep", "#{name}_Sheep.png")
    end

    WOOD_TYPES.each do |wood|
      %w[door trapdoor fence fence_gate button pressure_plate sign].each do |block|
        add_image("#{wood}_#{block}", "Invicon_#{file_case("#{wood}_#{block}")}.png")
      end
    end
    (SLABS + STAIRS).each { |id| add_image(id, "Invicon_#{file_case(id)}.png") }
    %w[redstone_torch soul_campfire deepslate_coal_ore].each { |id| add_image(id, "Invicon_#{file_case(id)}.png") }
    add_image('spectral_arrow', 'Invicon_Spectral_Arrow.png')
    add_image('map', 'Invicon_Map.png')
    add_image('empty_map', 'Invicon_Empty_Map.png')
    add_image('sweet_berry_bush', 'Sweet_Berry_Bush_Age_3.png')
    # Named "Arrow of <Effect>", with a few exceptions
    tipped_arrow_files = { 'water' => 'Splashing', 'turtle_master' => 'the_Turtle_Master', 'wind_charged' => 'Wind_Charging', 'infested' => 'Infestation' }
    TIPPED_ARROW_EFFECTS.each do |effect|
      add_image("#{effect}_tipped_arrow", "Invicon_Arrow_of_#{tipped_arrow_files[effect] || file_case(effect)}.png")
      MAPPINGS["#{effect}_tipped_arrow"][:name_key] = "item.minecraft.tipped_arrow.effect.#{effect}"
    end
    add_image('cod_entity', 'Cod.gif')
    add_image('pufferfish_entity', 'Pufferfish.png')
    add_image('tropical_fish_entity', 'Tropical_Fish.png')
    %w[powered_rail activator_rail iron_door copper_door iron_trapdoor copper_trapdoor nether_brick_fence
       stone_button polished_blackstone_button stone_pressure_plate polished_blackstone_pressure_plate
       light_weighted_pressure_plate heavy_weighted_pressure_plate].each do |id|
      add_image(id, "Invicon_#{file_case(id)}.png")
    end
    %w[spruce birch jungle acacia dark_oak mangrove cherry pale_oak azalea flowering_azalea].each do |wood|
      add_image("#{wood}_leaves", "Invicon_#{file_case(wood)}_Leaves.png")
    end
    BOAT_WOOD_TYPES.each { |wood| add_image("#{wood}_boat_entity", "#{file_case(wood)}_Boat.png") }
    add_image('bamboo_raft_entity', 'Bamboo_Raft.png')

    # Mob variants
    MOB_CLIMATES.each do |climate|
      name = file_case(climate)
      add_image("#{climate}_frog", "#{name}_Frog.gif")
      add_image("#{climate}_pig", "#{name}_Pig.png")
      add_image("#{climate}_cow", "#{name}_Cow.png")
      add_image("#{climate}_chicken", climate == 'temperate' ? 'Chicken.png' : "#{name}_Chicken.png")
    end
    %w[creamy white brown gray].each { |c| add_image("#{c}_llama", "EntitySprite_#{c}-llama.png") }
    %w[white creamy chestnut brown black gray].each { |c| add_image("#{c}_horse", "#{file_case(c)}_Horse.png") }
    add_image('dark_brown_horse', 'Darkbrown_Horse.png')
    %w[red blue green cyan gray].each { |c| add_image("#{c}_parrot", "#{file_case(c)}_Parrot.png") }
    %w[pale woods ashen black chestnut rusty spotted snowy striped].each { |c| add_image("#{c}_wolf", "#{file_case(c)}_Wolf.png") }
    add_image('red_fox', 'Fox.png')
    add_image('snow_fox', 'Snow_Fox.png')

    # Entries shown by an entry's icon: itself, or all members of a group (flattened)
    def self.leaves_of(id)
      data = MAPPINGS[id] or raise "symlink: unknown group member '#{id}'"
      return [id] unless data[:group]

      data[:group].flat_map { |member| leaves_of(member) }
    end

    def self.image_of(id)
      Jekyll::McImages.url_for(id) || MAPPINGS[id][:image]
    end

    # Name of an entry in the page's language: mob variants from _data/variant_names.yml,
    # everything else from the game's names in _data/game_names/<lang>.json
    def self.name_of(id, site)
      lang = site.active_lang
      variant = site.data.dig('variant_names', lang, id)
      return variant if variant

      names = site.data.dig('game_names', lang) || {}
      data = MAPPINGS[id]
      keys = if data[:name_key]
               [data[:name_key]]
             elsif id.end_with?('_entity')
               base = id.delete_suffix('_entity')
               ["entity.minecraft.#{base}", "item.minecraft.#{base}"]
             else
               ["block.minecraft.#{id}", "item.minecraft.#{id}", "entity.minecraft.#{id}"]
             end
      name = keys.map { |key| names[key] }.compact.first
      Jekyll.logger.warn "Symlink", "No #{lang} name for '#{id}'" unless name
      name
    end

    def initialize(tag_name, text, tokens)
      super
      @params = text.split(',').map(&:strip)
    end

    def render(context)
      id = @params[0]

      tag_data = MAPPINGS[id]

      # Just text if no mapping
      if (!tag_data)
        link_text = @params[1]
        # The marker stands in for the icon: before the text, and kept on its line
        return %Q{<span class="icon-link"><span class="mc-red">[🛠️]</span><span class="mc-gold">#{link_text}</span></span>}
      end

      if (tag_data[:pmc])
        text = tag_data[:text]
        mod_url = tag_data[:pmc]
        image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="56" height="58" viewBox="0 0 56 58" shapeRendering="crispEdges" class="pmc-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><g id="water"><path d="M0 38V36H19V38H52V47H51V48H50V49H47V51H46V52H45V53H44V54H38V56H37V57H36V58H20V57H19V56H18V54H11V53H10V52H9V51H8V49H6V48H5V47H4V40H2V39H1V38H0Z" fill="#012647"/><path d="M9 4H46V45H9V4Z" fill="#278EED"/><path d="M5 35H9V36H5V35Z" fill="#278EED"/><path d="M10 8H37V36H10V8Z" fill="#3DA2FF"/><path d="M37 18H42V32H37V18Z" fill="#3DA2FF"/><path d="M28 36H33V41H28V36Z" fill="#3DA2FF"/><path d="M33 36H37V41H33V36Z" fill="#2E95F4"/><path d="M37 32H42V36H37V32Z" fill="#2E95F4"/><path d="M18 8H28V22H18V8Z" fill="#57AAFF"/><path d="M18 22H23V27H18V22Z" fill="#57AAFF"/><path d="M33 8H37V18H33V8Z" fill="#4BA8FF"/><path d="M33 22H37V32H33V22Z" fill="#4BA8FF"/><path d="M28 27H33V36H28V27Z" fill="#4BA8FF"/><path d="M19 32H28V38H19V32Z" fill="#4BA8FF"/><path d="M9 41H14V45H9V41Z" fill="#0D74D3"/><path d="M19 48H23V50H19V48Z" fill="#0D74D3"/><path d="M46 32H48V36H46V32Z" fill="#0D74D3"/><path d="M46 18H49V27H46V18Z" fill="#0D74D3"/><path d="M42 36H46V45H42V36Z" fill="#0D74D3"/><path d="M37 41H42V45H37V41Z" fill="#0D74D3"/><path d="M9 45H19V50H9V45Z" fill="#014E96"/><path d="M19 50H37V55H19V50Z" fill="#014E96"/><path d="M37 45H46V50H37V45Z" fill="#014E96"/><path d="M46 36H51V45H46V36Z" fill="#014E96"/><path d="M19 0H37V4H19V0Z" fill="#0157A9"/><path d="M0 18H5V36H0V18Z" fill="#0157A9"/><path d="M5 36H9V45H5V36Z" fill="#0157A9"/><path d="M42 18H46V22H42V18Z" fill="#3198F7"/><path d="M51 38V36H56V38H55V39H54V40H52V38H51Z" fill="#132E2F"/></g><g id="land"><path d="M19 38H28V41H19V38Z" fill="#6EC310"/><path d="M23 14H24V16H23V14Z" fill="#6EC310"/><path d="M24 8H27V10H24V8Z" fill="#6EC310"/><path d="M24 18V16H25V17H26V18H24Z" fill="#6EC310"/><path d="M14 13V8H22V10H21V11H22V13H14Z" fill="#6EC310"/><path d="M14 22V13H9V22H5V35H9V36H14V34H12V33H10V30H11V29H14V30H15V31H16V27H18V22H14Z" fill="#6EC310"/><path d="M19 45V41H34V45H19Z" fill="#57B10F"/><path d="M5 22V18H9V22H5Z" fill="#57B10F"/><path d="M9 13V8H14V13H9Z" fill="#57B10F"/><path d="M19 8V4H28V6H27V8H24V7H22V8H19Z" fill="#57B10F"/><path d="M9 37V36H14V37H16V39H17V40H19V41H16V40H15V39H12V37H9Z" fill="#58AE01"/><path d="M39 11V8H46V17H45V13H42V11H39Z" fill="#448001"/><path d="M49 18H51V36H48V32H46V27H49V18Z" fill="#448001"/><path d="M37 50V45H19V48H23V50H37Z" fill="#448001"/><path d="M9 8V4H19V8H9V18H5V8H9Z" fill="#2A5401"/><path d="M37 8V4H46V8H51V18H56V36H51V18H46V8H37Z" fill="#2A5401"/><path d="M26 51V50H34V51H33V54H32V55H29V53H27V51H26Z" fill="#2A5401"/><path d="M51 38V36H49V37H50V38H51Z" fill="#2A5401"/></g><g id="sun"><path d="M14 22V13H23V22H14Z" fill="#ffffff"/></g></svg>'
        return %Q{<span class="mc-green icon-link">#{image_src}<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
      end

      if (tag_data[:modrinth])
        text = tag_data[:text]
        mod_url = tag_data[:modrinth]
        image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="514" viewBox="0 0 512 514" class="modrinth-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path fill="currentColor" fill-rule="evenodd" d="M503.16 323.56c11.39-42.09 12.16-87.65.04-132.8C466.57 54.23 326.04-26.8 189.33 9.78 83.81 38.02 11.39 128.07.69 230.47h43.3c10.3-83.14 69.75-155.74 155.76-178.76 106.3-28.45 215.38 28.96 253.42 129.67l-42.14 11.27c-19.39-46.85-58.46-81.2-104.73-95.83l-7.74 43.84c36.53 13.47 66.16 43.84 77 84.25 15.8 58.89-13.62 119.23-67 144.26l11.53 42.99c70.16-28.95 112.31-101.86 102.34-177.02l41.98-11.23a210.2 210.2 0 0 1-3.86 84.16z" clip-rule="evenodd"></path><path fill="currentColor" d="M321.99 504.22C185.27 540.8 44.75 459.77 8.11 323.24A257.6 257.6 0 0 1 0 275.46h43.27c1.09 11.91 3.2 23.89 6.41 35.83 3.36 12.51 7.77 24.46 13.11 35.78l38.59-23.15c-3.25-7.5-5.99-15.32-8.17-23.45-24.04-89.6 29.2-181.7 118.92-205.71 17-4.55 34.1-6.32 50.8-5.61L255.19 133c-10.46.05-21.08 1.42-31.66 4.25-66.22 17.73-105.52 85.7-87.78 151.84 1.1 4.07 2.38 8.04 3.84 11.9l49.35-29.61-14.87-39.43 46.6-47.87 58.9-12.69 17.05 20.99-27.15 27.5-23.68 7.45-16.92 17.39 8.29 23.07s16.79 17.84 16.82 17.85l23.72-6.31 16.88-18.54 36.86-11.67 10.98 24.7-38.03 46.63-63.73 20.18-28.58-31.82-49.82 29.89c25.54 29.08 63.94 45.23 103.75 41.86l11.53 42.99c-59.41 7.86-117.44-16.73-153.49-61.91l-38.41 23.04c50.61 66.49 138.2 99.43 223.97 76.48 61.74-16.52 109.79-58.6 135.81-111.78l42.64 15.5c-30.89 66.28-89.84 118.94-166.07 139.34"></path></svg>'
        return %Q{<span class="mc-green icon-link">#{image_src}<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
      end

      if (tag_data[:github])
        text = tag_data[:text]
        mod_url = tag_data[:github]
        image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" class="github-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path fill="currentColor" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"></path></svg>'
        return %Q{<span class="mc-green icon-link">#{image_src}<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
      end

      if (tag_data[:curseforge])
        text = tag_data[:text]
        mod_url = tag_data[:curseforge]
        image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32" class="curseforge-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path d="M23.9074 12.0181C23.9074 12.0181 30.0327 11.0522 31 8.23523H21.6168V6H1L3.53975 8.94699V11.9664C3.53975 11.9664 9.94812 11.6332 12.427 13.5129C15.8202 16.6579 8.61065 20.9092 8.61065 20.9092L7.37439 25C9.30758 23.1593 12.9921 20.7781 19.7474 20.8929C17.1767 21.7053 14.5917 22.9743 12.5794 25H26.2354L24.9494 20.9092C24.9494 20.9092 15.0519 15.0732 23.9074 12.0184V12.0181Z" fill="#f16436" /></svg>'
        return %Q{<span class="mc-green icon-link">#{image_src}<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
      end


      link_text = @params[1]
      leaves = self.class.leaves_of(id)
      images = leaves.map { |leaf| self.class.image_of(leaf) }
      image_src = images.first
      # Enchantments without an own image use the enchanted book
      if !image_src && [:enchantment, :curse].include?(tag_data[:kind])
        image_src = Jekyll::McImages.url_for('enchanted_book') || MAPPINGS['enchanted_book'][:image]
      end
      emoji_src = tag_data[:emoji]
      current_url = context.environments.first['page']['url'] || context.environments.first['page']['permalink']

      # Icons are decorative (empty alt), as the name follows right after them
      icon = if emoji_src
               %Q{<span>#{emoji_src}</span>}
             elsif images.length > 1
               # Cycled through by wiki.js, with a tooltip naming the currently shown member
               site = context.registers[:site]
               names = leaves.map { |leaf| self.class.name_of(leaf, site) || '' }
               %Q{<img src="#{image_src}" data-cycle="#{images.join(' ')}" data-cycle-names="#{CGI.escapeHTML(names.join('|'))}" alt="" draggable="false" class="pixelated img-link img-cycle">}
             elsif image_src
               %Q{<img src="#{image_src}" alt="" draggable="false" class="pixelated img-link">}
             end

      text_class = tag_data[:text_class] || KIND_CLASSES[tag_data[:kind]] || 'mc-gold'
      link_text = "«#{link_text}»" if tag_data[:kind]

      # No link if link is missing or the current page is the same
      if !tag_data[:url] || current_url == tag_data[:url]
        text = %Q{<span class="#{text_class}">#{link_text}</span>}
      else
        wiki_url = context.registers[:site].config['url'] + tag_data[:url]
        text = %Q{<a href="#{wiki_url}" class="wiki-link #{text_class}">#{link_text}</a>}
      end

      return text unless icon

      %Q{<span class="icon-link">#{icon}#{text}</span>}
    end
  end
end

Jekyll::Hooks.register :site, :pre_render do |site|
  Jekyll.logger.info "McImages", "Resolving Minecraft Wiki image URLs..."
  Jekyll::McImages.resolve!(Jekyll::SymlinkTag::MAPPINGS)

  total  = Jekyll::SymlinkTag::MAPPINGS.count { |_, v| v[:image] }
  failed = Jekyll::McImages.failed.size
  Jekyll.logger.info "McImages", "Resolved #{total - failed}/#{total} image URLs (#{failed} failed)"
end

Liquid::Template.register_tag('symlink', Jekyll::SymlinkTag)
