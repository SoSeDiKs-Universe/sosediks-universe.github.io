module Jekyll
    class SymlinkTag < Liquid::Tag
  
      MAPPINGS = {
        # Entities
        'wandering_trader' => {
          image: 'https://minecraft.wiki/images/EntitySprite_wandering-trader.png',
          url: '/wiki/entity/wandering_trader'
        },
        'player' => {
          image: 'https://minecraft.wiki/images/EntitySprite_steve.png',
          url: '/wiki/entity/player'
        },
        'llama' => {
          image: 'https://minecraft.wiki/images/EntitySprite_creamy-llama.png'
        },
        'sheep' => {
          image: 'https://minecraft.wiki/images/White_Sheep_JE5.png'
        },
        'rainbow_sheep' => {
          image: 'https://minecraft.wiki/images/Jeb_Sheep_JE4_BE3.webp'
        },
        'silverfish' => {
          image: 'https://minecraft.wiki/images/Silverfish_JE1_BE1.gif'
        },
        'evoker' => {
          image: 'https://minecraft.wiki/images/Evoker_JE3.png'
        },
        'creeper' => {
          image: 'https://minecraft.wiki/images/Creeper_JE3_BE1.png'
        },
        'enderman' => {
          image: 'https://minecraft.wiki/images/Enderman_JE3_BE1.png'
        },
        'skeleton' => {
          image: 'https://minecraft.wiki/images/Skeleton_JE6_BE4.png'
        },
        'stray' => {
          image: 'https://minecraft.wiki/images/Stray_JE2_BE4.png'
        },
        'bogged' => {
          image: 'https://minecraft.wiki/images/Bogged_JE2_BE2.png'
        },
        'wither_skeleton' => {
          image: 'https://minecraft.wiki/images/Wither_Skeleton_JE4_BE3.png'
        },
        'slime' => {
          image: 'https://minecraft.wiki/images/Slime_JE3_BE2.png'
        },
        'armor_stand_entity' => {
          image: 'https://minecraft.wiki/images/Armor_Stand_JE5.png'
        },
        'oak_boat_entity' => {
          image: 'https://minecraft.wiki/images/thumb/Oak_Boat_JE4_BE2.png/150px-Oak_Boat_JE4_BE2.png'
        },
        'minecart_entity' => {
          image: 'https://minecraft.wiki/images/Minecart_JE4_BE2.png'
        },
        'tnt_minecart_entity' => {
          image: 'https://minecraft.wiki/images/Minecart_with_TNT_JE2_BE2.png'
        },
        'shulker_open' => {
          image: 'https://minecraft.wiki/images/Shulker_JE1_BE1.png'
        },
        # Items
        'bucket' => {
          image: 'https://minecraft.wiki/images/Invicon_Bucket.png'
        },
        'water_bucket' => {
          image: 'https://minecraft.wiki/images/Invicon_Water_Bucket.png'
        },
        'lava_bucket' => {
          image: 'https://minecraft.wiki/images/Invicon_Lava_Bucket.png'
        },
        'blaze_powder' => {
          image: 'https://minecraft.wiki/images/Invicon_Blaze_Powder.png'
        },
        'blaze_rod' => {
          image: 'https://minecraft.wiki/images/Invicon_Blaze_Rod.png'
        },
        'fire_charge' => {
          image: 'https://minecraft.wiki/images/Invicon_Fire_Charge.png'
        },
        'flint_and_steel' => {
          image: 'https://minecraft.wiki/images/Flint_and_Steel_JE4_BE2.png'
        },
        'shears' => {
          image: 'https://minecraft.wiki/images/Shears_JE2_BE2.png'
        },
        'wooden_shovel' => {
          image: 'https://minecraft.wiki/images/Wooden_Shovel_JE2_BE2.png'
        },
        'magma_cream' => {
          image: 'https://minecraft.wiki/images/Invicon_Magma_Cream.png'
        },
        'torch' => {
          image: 'https://minecraft.wiki/images/Invicon_Torch.png'
        },
        'soul_torch' => {
          image: 'https://minecraft.wiki/images/Invicon_Soul_Torch.pngg'
        },
        'saddle' => {
          image: 'https://minecraft.wiki/images/Invicon_Saddle.png'
        },
        'glass_bottle' => {
          image: 'https://minecraft.wiki/images/Invicon_Glass_Bottle.png'
        },
        'potion' => {
          image: 'https://minecraft.wiki/images/Invicon_Water_Bottle.png'
        },
        'water_potion' => {
          image: 'https://minecraft.wiki/images/Invicon_Water_Bottle.png'
        },
        'splash_water_potion' => {
          image: 'https://minecraft.wiki/images/Invicon_Splash_Water_Bottle.png'
        },
        'lingering_water_potion' => {
          image: 'https://minecraft.wiki/images/Invicon_Lingering_Water_Bottle.png'
        },
        'honey_bottle' => {
          image: 'https://minecraft.wiki/images/Invicon_Honey_Bottle.png'
        },
        'leather_helmet' => {
          image: 'https://minecraft.wiki/images/Invicon_Leather_Cap.png'
        },
        'leather_chestplate' => {
          image: 'https://minecraft.wiki/images/Invicon_Leather_Tunic.png'
        },
        'item_frame' => {
          image: 'https://minecraft.wiki/images/Invicon_Item_Frame.png'
        },
        'painting' => {
          image: 'https://minecraft.wiki/images/Invicon_Painting.png'
        },
        'paper' => {
          image: 'https://minecraft.wiki/images/Paper_JE2_BE2.png'
        },
        'writable_book' => {
          image: 'https://minecraft.wiki/images/Invicon_Book_and_Quill.png'
        },
        'clock' => {
          image: 'https://minecraft.wiki/images/Clock_JE3_BE3.gif'
        },
        'compass' => {
          image: 'https://minecraft.wiki/images/Compass_JE3_BE3.gif'
        },
        'poisonous_potato' => {
          image: 'https://minecraft.wiki/images/Poisonous_Potato_JE3_BE2.png'
        },
        'arrow' => {
          image: 'https://minecraft.wiki/images/Arrow_(item)_JE1_BE1.png'
        },
        'snowball' => {
          image: 'https://minecraft.wiki/images/Snowball_JE3_BE3.png'
        },
        'red_mushroom' => {
          image: 'https://minecraft.wiki/images/Invicon_Red_Mushroom.png'
        },
        'brown_mushroom' => {
          image: 'https://minecraft.wiki/images/Invicon_Brown_Mushroom.png'
        },
        'trident' => {
          image: 'https://minecraft.wiki/images/Trident_(item).png'
        },
        'grass_block' => {
          image: 'https://minecraft.wiki/images/Grass_Block_JE7_BE6.png'
        },
        'podzol' => {
          image: 'https://minecraft.wiki/images/Podzol_JE2_BE2.png'
        },
        'gravel' => {
          image: 'https://minecraft.wiki/images/Gravel_JE5_BE4.png'
        },
        'sand' => {
          image: 'https://minecraft.wiki/images/Sand_JE5_BE3.png'
        },
        'sandstone' => {
          image: 'https://minecraft.wiki/images/Sandstone_JE6_BE3.png'
        },
        'red_sand' => {
          image: 'https://minecraft.wiki/images/Red_Sand_JE3_BE2.png'
        },
        'red_sandstone' => {
          image: 'https://minecraft.wiki/images/Red_Sandstone_JE4_BE2.png'
        },
        'water_cauldron' => {
          image: 'https://minecraft.wiki/images/Water_Cauldron_JE7.png'
        },
        'cracked_stone_bricks' => {
          image: 'https://minecraft.wiki/images/Cracked_Stone_Bricks_JE3_BE2.png'
        },
        'glass' => {
          image: 'https://minecraft.wiki/images/Invicon_Glass.png'
        },
        'lava' => {
          image: 'https://minecraft.wiki/images/thumb/Lava_JE14.gif/150px-Lava_JE14.gif'
        },
        'water' => {
          image: 'https://minecraft.wiki/images/Water_JE16-a1.png'
        },
        'campfire' => {
          image: 'https://minecraft.wiki/images/Invicon_Campfire.png'
        },
        'campfire_block_unlit' => {
          image: 'https://minecraft.wiki/images/Unlit_Campfire_%28S%29_JE2_BE2.png'
        },
        'oak_door' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Door.png'
        },
        'oak_trapdoor' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Trapdoor.png'
        },
        'oak_fence' => {
          image: 'https://minecraft.wiki/images/Oak_Fence_(item)_JE3_BE2.png'
        },
        'oak_fence_gate' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Fence_Gate.png'
        },
        'oak_button' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Button.png'
        },
        'oak_sign' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Sign.png'
        },
        'oak_pressure_plate' => {
          image: 'https://minecraft.wiki/images/Oak_Pressure_Plate_JE5_BE2.png'
        },
        'oak_slab' => {
          image: 'https://minecraft.wiki/images/Oak_Slab_JE5_BE2.png'
        },
        'oak_stairs' => {
          image: 'https://minecraft.wiki/images/Oak_Stairs_(N)_JE7_BE6.png'
        },
        'oak_leaves' => {
          image: 'https://minecraft.wiki/images/Oak_Leaves.png'
        },
        'magma_block' => {
          image: 'https://minecraft.wiki/images/Invicon_Magma_Block.gif'
        },
        'chest' => {
          image: 'https://minecraft.wiki/images/Invicon_Chest.png'
        },
        'note_block' => {
          image: 'https://minecraft.wiki/images/Note_Block_JE2_BE2.png'
        },
        'ice' => {
          image: 'https://minecraft.wiki/images/Ice_JE4_BE6.png'
        },
        'packed_ice' => {
          image: 'https://minecraft.wiki/images/Packed_Ice_JE2_BE3.png'
        },
        'blue_ice' => {
          image: 'https://minecraft.wiki/images/Blue_Ice_JE3_BE2.png'
        },
        'snow_layer_1' => {
          image: 'https://minecraft.wiki/images/Snow_(layers_1)_JE3_BE3.png'
        },
        'snow_block' => {
          image: 'https://minecraft.wiki/images/Snow_Block_JE2_BE2.png'
        },
        'slime_block' => {
          image: 'https://minecraft.wiki/images/Slime_Block_JE2_BE3.png'
        },
        'melon' => {
          image: 'https://minecraft.wiki/images/Melon_JE2_BE2.png'
        },
        'pumpkin' => {
          image: 'https://minecraft.wiki/images/Carved_Pumpkin_(N)_JE5.png'
        },
        'jack_o_lantern' => {
          image: 'https://minecraft.wiki/images/Jack_o\'Lantern_(S)_JE4.png'
        },
        'cobweb' => {
          image: 'https://minecraft.wiki/images/Invicon_Cobweb.png'
        },
        'tnt' => {
          image: 'https://minecraft.wiki/images/TNT_JE3_BE2.png'
        },
        'candle' => {
          image: 'https://minecraft.wiki/images/Candle_JE1_BE1.png'
        },
        'candle_cake' => {
          image: 'https://minecraft.wiki/images/Cake_with_Candle_JE1_BE1.png'
        },
        'coal_ore' => {
          image: 'https://minecraft.wiki/images/Coal_Ore_JE5_BE4.png'
        },
        'fire' => {
          image: 'https://minecraft.wiki/images/Fire.gif'
        },
        'dirt' => {
          image: 'https://minecraft.wiki/images/Dirt.png'
        },
        'coarse_dirt' => {
          image: 'https://minecraft.wiki/images/Coarse_Dirt.png'
        },
        'dirt_path' => {
          image: 'https://minecraft.wiki/images/Dirt_Path_JE4_BE3.png'
        },
        'farmland' => {
          image: 'https://minecraft.wiki/images/Farmland_JE4_BE6.png'
        },
        'wither_rose' => {
          image: 'https://minecraft.wiki/images/Invicon_Wither_Rose.png'
        },
        'wither_skeleton_skull' => {
          image: 'https://minecraft.wiki/images/Wither_Skeleton_Skull_%28S%29_JE2.png'
        },
        'white_carpet' => {
          image: 'https://minecraft.wiki/images/White_Carpet_JE2_BE2.png'
        },
        'red_bed' => {
          image: 'https://minecraft.wiki/images/Red_Bed_(N).png'
        },
        'bee_nest' => {
          image: 'https://minecraft.wiki/images/Bee_Nest_(S)_JE1.png'
        },
        'flower_pot' => {
          image: 'https://minecraft.wiki/images/Invicon_Flower_Pot.png'
        },
        # Potion effects
        'fire_resistance' => {
          image: 'https://minecraft.wiki/images/Fire_Resistance_JE2_BE2.png'
        },
        # Internal items
        'gloves' => {
          emoji: '🧤',
          url: '/wiki/mechanics/gloves'
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
        'realm-rpg-fallen-adventurers' => {
          text: 'Realm RPG: Fallen Adventurers',
          modrinth: 'https://modrinth.com/mod/realm-rpg-fallen-adventurers'
        },
        'berry-good' => {
          text: 'Berry Good',
          modrinth: 'https://modrinth.com/mod/berry-good'
        },
        'urkaz-moon-tools' => {
          text: 'Urkaz Moon Tools',
          modrinth: 'https://modrinth.com/mod/urkaz-moon-tools'
        },
        'blazeandcaves-advancements-pack' => {
          text: 'BlazeandCave\'s Advancements Pack',
          modrinth: 'https://modrinth.com/datapack/blazeandcaves-advancements-pack'
        }
      }
  
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
          return %Q{<span class="mc-gold">#{link_text}</span>&nbsp;<span class="mc-red">[🛠️]</span>}
        end

        if (tag_data[:modrinth])
          text = tag_data[:text]
          mod_url = tag_data[:modrinth]
          image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="514" viewBox="0 0 512 514" class="modrinth-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path fill="currentColor" fill-rule="evenodd" d="M503.16 323.56c11.39-42.09 12.16-87.65.04-132.8C466.57 54.23 326.04-26.8 189.33 9.78 83.81 38.02 11.39 128.07.69 230.47h43.3c10.3-83.14 69.75-155.74 155.76-178.76 106.3-28.45 215.38 28.96 253.42 129.67l-42.14 11.27c-19.39-46.85-58.46-81.2-104.73-95.83l-7.74 43.84c36.53 13.47 66.16 43.84 77 84.25 15.8 58.89-13.62 119.23-67 144.26l11.53 42.99c70.16-28.95 112.31-101.86 102.34-177.02l41.98-11.23a210.2 210.2 0 0 1-3.86 84.16z" clip-rule="evenodd"></path><path fill="currentColor" d="M321.99 504.22C185.27 540.8 44.75 459.77 8.11 323.24A257.6 257.6 0 0 1 0 275.46h43.27c1.09 11.91 3.2 23.89 6.41 35.83 3.36 12.51 7.77 24.46 13.11 35.78l38.59-23.15c-3.25-7.5-5.99-15.32-8.17-23.45-24.04-89.6 29.2-181.7 118.92-205.71 17-4.55 34.1-6.32 50.8-5.61L255.19 133c-10.46.05-21.08 1.42-31.66 4.25-66.22 17.73-105.52 85.7-87.78 151.84 1.1 4.07 2.38 8.04 3.84 11.9l49.35-29.61-14.87-39.43 46.6-47.87 58.9-12.69 17.05 20.99-27.15 27.5-23.68 7.45-16.92 17.39 8.29 23.07s16.79 17.84 16.82 17.85l23.72-6.31 16.88-18.54 36.86-11.67 10.98 24.7-38.03 46.63-63.73 20.18-28.58-31.82-49.82 29.89c25.54 29.08 63.94 45.23 103.75 41.86l11.53 42.99c-59.41 7.86-117.44-16.73-153.49-61.91l-38.41 23.04c50.61 66.49 138.2 99.43 223.97 76.48 61.74-16.52 109.79-58.6 135.81-111.78l42.64 15.5c-30.89 66.28-89.84 118.94-166.07 139.34"></path></svg>'
          return %Q{<span style="display: inline-flex; align-items: center;" class="mc-green">#{image_src}&nbsp;<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
        end
  

        link_text = @params[1]
        image_src = tag_data[:image]
        emoji_src = tag_data[:emoji]
        current_url = context.environments.first['page']['url'] || context.environments.first['page']['permalink']
  
        # No link if link is missing or the current page is the same
        if !tag_data[:url] || current_url == tag_data[:url]
          if (emoji_src)
            return %Q{#{emoji_src}&nbsp;<span class="mc-gold">#{link_text}</span>}
          else
            return %Q{<span style="display: inline-flex; align-items: center;"><img src="#{image_src}" alt="#{link_text}" draggable="false" class="pixelated img-link">&nbsp;<span class="mc-gold">#{link_text}</span></span>}
          end
        end

        wiki_url = context.registers[:site].config['url'] + tag_data[:url]

        if (emoji_src)
          return %Q{#{emoji_src}&nbsp;<a href="#{wiki_url}" class="wiki-link mc-gold">#{link_text}</a>}
        else
          return %Q{<span style="display: inline-flex; align-items: center;"><img src="#{image_src}" alt="#{link_text}" draggable="false" class="pixelated img-link">&nbsp;<a href="#{wiki_url}" class="wiki-link mc-gold">#{link_text}</a></span>}
        end
      end
    end
  end
  
  Liquid::Template.register_tag('symlink', Jekyll::SymlinkTag)
  