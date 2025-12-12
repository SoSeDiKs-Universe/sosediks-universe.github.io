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
        'chicken' => {
          image: 'https://minecraft.wiki/images/Chicken_JE2_BE2.png'
        },
        'baby_chicken' => {
          image: 'https://minecraft.wiki/images/Baby_Chicken_JE2_BE2.png'
        },
        'horse' => {
          image: 'https://minecraft.wiki/images/White_Horse.png'
        },
        'mule' => {
          image: 'https://minecraft.wiki/images/Mule_JE5.png'
        },
        'zombie_horse' => {
          image: 'https://minecraft.wiki/images/Zombie_Horse_JE6.png'
        },
        'skeleton_horse' => {
          image: 'https://minecraft.wiki/images/Skeleton_Horse.png'
        },
        'frog' => {
          image: 'https://minecraft.wiki/images/Temperate_Frog_JE1_BE1.gif'
        },
        'squid' => {
          image: 'https://minecraft.wiki/images/Squid.gif'
        },
        'glow_squid' => {
          image: 'https://minecraft.wiki/images/Glow_Squid_JE1.gif'
        },
        'allay' => {
          image: 'https://minecraft.wiki/images/Allay_JE2_BE2.gif'
        },
        'vex' => {
          image: 'https://minecraft.wiki/images/Vex_JE4.gif'
        },
        'strider' => {
          image: 'https://minecraft.wiki/images/Strider_JE2_BE2.gif'
        },
        'nautilus' => {
          image: 'https://minecraft.wiki/images/Nautilus_Breathe_JE1_BE2.gif'
        },
        'zombie_nautilus' => {
          image: 'https://minecraft.wiki/images/Zombie_Nautilus_Breathe_JE1_BE2.gif'
        },
        'pillager' => {
          image: 'https://minecraft.wiki/images/Pillager_JE3.png'
        },
        'polar_bear' => {
          image: 'https://minecraft.wiki/images/Polar_Bear_JE2_BE2.png'
        },
        'salmon_fish' => {
          image: 'https://minecraft.wiki/images/Salmon.gif'
        },
        'ocelot' => {
          image: 'https://minecraft.wiki/images/Ocelot_JE2_BE2.png'
        },
        'phantom' => {
          image: 'https://minecraft.wiki/images/Phantom_JE2.gif'
        },
        'parrot' => {
          image: 'https://minecraft.wiki/images/Red_Parrot_JE1_BE1.png'
        },
        'wolf' => {
          image: 'https://minecraft.wiki/images/Wolf_JE2_BE2.png'
        },
        'pig' => {
          image: 'https://minecraft.wiki/images/Temperate_Pig_JE4_BE2.png'
        },
        'silverfish' => {
          image: 'https://minecraft.wiki/images/Silverfish_JE1_BE1.gif'
        },
        'endermite' => {
          image: 'https://minecraft.wiki/images/Endermite.gif'
        },
        'ghast' => {
          image: 'https://minecraft.wiki/images/Ghast_JE3_BE3.gif'
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
        'parched' => {
          image: 'https://minecraft.wiki/images/Parched_JE2.png'
        },
        'wither_skeleton' => {
          image: 'https://minecraft.wiki/images/Wither_Skeleton_JE4_BE3.png'
        },
        'slime' => {
          image: 'https://minecraft.wiki/images/Slime_JE3_BE2.png'
        },
        'magma_cube' => {
          image: 'https://minecraft.wiki/images/Magma_Cube_JE2_BE2.png'
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
        'snowman_sheared' => {
          image: 'https://minecraft.wiki/images/Sheared_Snow_Golem_JE2_BE2.png'
        },
        'fox' => {
          image: 'https://minecraft.wiki/images/Fox_JE1_BE1.png'
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
          image: 'https://minecraft.wiki/images/Invicon_Soul_Torch.png'
        },
        'copper_torch' => {
          image: 'https://minecraft.wiki/images/Invicon_Copper_Torch_JE2_BE2.png'
        },
        'saddle' => {
          image: 'https://minecraft.wiki/images/Invicon_Saddle.png'
        },
        'feather' => {
          image: 'https://minecraft.wiki/images/Feather_JE3_BE2.png'
        },
        'rotten_flesh' => {
          image: 'https://minecraft.wiki/images/Rotten_Flesh_JE3_BE2.png'
        },
        'bone_meal' => {
          image: 'https://minecraft.wiki/images/Bone_Meal_JE3_BE3.png'
        },
        'crossbow' => {
          image: 'https://minecraft.wiki/images/Crossbow.png'
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
        'egg' => {
          image: 'https://minecraft.wiki/images/Egg_JE2_BE2.png'
        },
        'spyglass' => {
          image: 'https://minecraft.wiki/images/Spyglass_(item)_JE3_BE1.png'
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
        'cactus' => {
          image: 'https://minecraft.wiki/images/Cactus_JE4.png'
        },
        'sweet_berries' => {
          image: 'https://minecraft.wiki/images/Sweet_Berry_Bush_Age_3_JE1_BE1.png'
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
        'crying_obsidian' => {
          image: 'https://minecraft.wiki/images/Crying_Obsidian_JE1_BE1.png'
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
        'carved_pumpkin' => {
          image: 'https://minecraft.wiki/images/Carved_Pumpkin_(S)_JE5.png'
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
        'blindness' => {
          image: 'https://minecraft.wiki/images/Blindness_JE2_BE2.png'
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
        'kfa' => {
          text: 'Kentucky Fried Axolotls',
          modrinth: 'https://modrinth.com/mod/kfa'
        },
        'axolotl-bucket-fix' => {
          text: 'Axolotl Bucket Fix',
          modrinth: 'https://modrinth.com/mod/axolotl-bucket-fix'
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
        'chainmail-bucket' => {
          text: 'Chainmail Bucket',
          curseforge: 'https://modrinth.com/mod/chainmail-bucket'
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

        if (tag_data[:pmc])
          text = tag_data[:text]
          mod_url = tag_data[:pmc]
          image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="56" height="58" viewBox="0 0 56 58" shapeRendering="crispEdges" class="pmc-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><g id="water"><path d="M0 38V36H19V38H52V47H51V48H50V49H47V51H46V52H45V53H44V54H38V56H37V57H36V58H20V57H19V56H18V54H11V53H10V52H9V51H8V49H6V48H5V47H4V40H2V39H1V38H0Z" fill="#012647"/><path d="M9 4H46V45H9V4Z" fill="#278EED"/><path d="M5 35H9V36H5V35Z" fill="#278EED"/><path d="M10 8H37V36H10V8Z" fill="#3DA2FF"/><path d="M37 18H42V32H37V18Z" fill="#3DA2FF"/><path d="M28 36H33V41H28V36Z" fill="#3DA2FF"/><path d="M33 36H37V41H33V36Z" fill="#2E95F4"/><path d="M37 32H42V36H37V32Z" fill="#2E95F4"/><path d="M18 8H28V22H18V8Z" fill="#57AAFF"/><path d="M18 22H23V27H18V22Z" fill="#57AAFF"/><path d="M33 8H37V18H33V8Z" fill="#4BA8FF"/><path d="M33 22H37V32H33V22Z" fill="#4BA8FF"/><path d="M28 27H33V36H28V27Z" fill="#4BA8FF"/><path d="M19 32H28V38H19V32Z" fill="#4BA8FF"/><path d="M9 41H14V45H9V41Z" fill="#0D74D3"/><path d="M19 48H23V50H19V48Z" fill="#0D74D3"/><path d="M46 32H48V36H46V32Z" fill="#0D74D3"/><path d="M46 18H49V27H46V18Z" fill="#0D74D3"/><path d="M42 36H46V45H42V36Z" fill="#0D74D3"/><path d="M37 41H42V45H37V41Z" fill="#0D74D3"/><path d="M9 45H19V50H9V45Z" fill="#014E96"/><path d="M19 50H37V55H19V50Z" fill="#014E96"/><path d="M37 45H46V50H37V45Z" fill="#014E96"/><path d="M46 36H51V45H46V36Z" fill="#014E96"/><path d="M19 0H37V4H19V0Z" fill="#0157A9"/><path d="M0 18H5V36H0V18Z" fill="#0157A9"/><path d="M5 36H9V45H5V36Z" fill="#0157A9"/><path d="M42 18H46V22H42V18Z" fill="#3198F7"/><path d="M51 38V36H56V38H55V39H54V40H52V38H51Z" fill="#132E2F"/></g><g id="land"><path d="M19 38H28V41H19V38Z" fill="#6EC310"/><path d="M23 14H24V16H23V14Z" fill="#6EC310"/><path d="M24 8H27V10H24V8Z" fill="#6EC310"/><path d="M24 18V16H25V17H26V18H24Z" fill="#6EC310"/><path d="M14 13V8H22V10H21V11H22V13H14Z" fill="#6EC310"/><path d="M14 22V13H9V22H5V35H9V36H14V34H12V33H10V30H11V29H14V30H15V31H16V27H18V22H14Z" fill="#6EC310"/><path d="M19 45V41H34V45H19Z" fill="#57B10F"/><path d="M5 22V18H9V22H5Z" fill="#57B10F"/><path d="M9 13V8H14V13H9Z" fill="#57B10F"/><path d="M19 8V4H28V6H27V8H24V7H22V8H19Z" fill="#57B10F"/><path d="M9 37V36H14V37H16V39H17V40H19V41H16V40H15V39H12V37H9Z" fill="#58AE01"/><path d="M39 11V8H46V17H45V13H42V11H39Z" fill="#448001"/><path d="M49 18H51V36H48V32H46V27H49V18Z" fill="#448001"/><path d="M37 50V45H19V48H23V50H37Z" fill="#448001"/><path d="M9 8V4H19V8H9V18H5V8H9Z" fill="#2A5401"/><path d="M37 8V4H46V8H51V18H56V36H51V18H46V8H37Z" fill="#2A5401"/><path d="M26 51V50H34V51H33V54H32V55H29V53H27V51H26Z" fill="#2A5401"/><path d="M51 38V36H49V37H50V38H51Z" fill="#2A5401"/></g><g id="sun"><path d="M14 22V13H23V22H14Z" fill="#ffffff"/></g></svg>'
          return %Q{<span style="display: inline-flex; align-items: center;" class="mc-green">#{image_src}&nbsp;<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
        end

        if (tag_data[:modrinth])
          text = tag_data[:text]
          mod_url = tag_data[:modrinth]
          image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="514" viewBox="0 0 512 514" class="modrinth-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path fill="currentColor" fill-rule="evenodd" d="M503.16 323.56c11.39-42.09 12.16-87.65.04-132.8C466.57 54.23 326.04-26.8 189.33 9.78 83.81 38.02 11.39 128.07.69 230.47h43.3c10.3-83.14 69.75-155.74 155.76-178.76 106.3-28.45 215.38 28.96 253.42 129.67l-42.14 11.27c-19.39-46.85-58.46-81.2-104.73-95.83l-7.74 43.84c36.53 13.47 66.16 43.84 77 84.25 15.8 58.89-13.62 119.23-67 144.26l11.53 42.99c70.16-28.95 112.31-101.86 102.34-177.02l41.98-11.23a210.2 210.2 0 0 1-3.86 84.16z" clip-rule="evenodd"></path><path fill="currentColor" d="M321.99 504.22C185.27 540.8 44.75 459.77 8.11 323.24A257.6 257.6 0 0 1 0 275.46h43.27c1.09 11.91 3.2 23.89 6.41 35.83 3.36 12.51 7.77 24.46 13.11 35.78l38.59-23.15c-3.25-7.5-5.99-15.32-8.17-23.45-24.04-89.6 29.2-181.7 118.92-205.71 17-4.55 34.1-6.32 50.8-5.61L255.19 133c-10.46.05-21.08 1.42-31.66 4.25-66.22 17.73-105.52 85.7-87.78 151.84 1.1 4.07 2.38 8.04 3.84 11.9l49.35-29.61-14.87-39.43 46.6-47.87 58.9-12.69 17.05 20.99-27.15 27.5-23.68 7.45-16.92 17.39 8.29 23.07s16.79 17.84 16.82 17.85l23.72-6.31 16.88-18.54 36.86-11.67 10.98 24.7-38.03 46.63-63.73 20.18-28.58-31.82-49.82 29.89c25.54 29.08 63.94 45.23 103.75 41.86l11.53 42.99c-59.41 7.86-117.44-16.73-153.49-61.91l-38.41 23.04c50.61 66.49 138.2 99.43 223.97 76.48 61.74-16.52 109.79-58.6 135.81-111.78l42.64 15.5c-30.89 66.28-89.84 118.94-166.07 139.34"></path></svg>'
          return %Q{<span style="display: inline-flex; align-items: center;" class="mc-green">#{image_src}&nbsp;<a href="#{mod_url}" class="wiki-link mc-gold">#{text}</a></span>}
        end

        if (tag_data[:curseforge])
          text = tag_data[:text]
          mod_url = tag_data[:curseforge]
          image_src = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32" class="curseforge-icon brand-icon pixelated img-link" style="width: 1em; height: 1em;"><path d="M23.9074 12.0181C23.9074 12.0181 30.0327 11.0522 31 8.23523H21.6168V6H1L3.53975 8.94699V11.9664C3.53975 11.9664 9.94812 11.6332 12.427 13.5129C15.8202 16.6579 8.61065 20.9092 8.61065 20.9092L7.37439 25C9.30758 23.1593 12.9921 20.7781 19.7474 20.8929C17.1767 21.7053 14.5917 22.9743 12.5794 25H26.2354L24.9494 20.9092C24.9494 20.9092 15.0519 15.0732 23.9074 12.0184V12.0181Z" fill="#f16436" /></svg>'
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
  