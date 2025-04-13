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
          image: 'https://minecraft.wiki/images/White_Sheep_JE3_BE6.png'
        },
        'rainbow_sheep' => {
          image: 'https://minecraft.wiki/images/Jeb_Sheep_JE2.gif'
        },
        'creeper' => {
          image: 'https://minecraft.wiki/images/Creeper_JE3_BE1.png'
        },
        'enderman' => {
          image: 'https://minecraft.wiki/images/Enderman_JE3_BE1.png'
        },
        'armor_stand_entity' => {
          image: 'https://minecraft.wiki/images/Armor_Stand_JE5.png'
        },
        'oak_boat_entity' => {
          image: 'https://minecraft.wiki/images/thumb/Oak_Boat_JE4_BE2.png/150px-Oak_Boat_JE4_BE2.png'
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
        'magma_cream' => {
          image: 'https://minecraft.wiki/images/Invicon_Magma_Cream.png'
        },
        'torch' => {
          image: 'https://minecraft.wiki/images/Invicon_Torch.png'
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
        'potion_water' => {
          image: 'https://minecraft.wiki/images/Invicon_Water_Bottle.png'
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
        'arrow' => {
          image: 'https://minecraft.wiki/images/Arrow_(item)_JE1_BE1.png'
        },
        'trident' => {
          image: 'https://minecraft.wiki/images/Trident_(item).png'
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
        'melon' => {
          image: 'https://minecraft.wiki/images/Melon_JE2_BE2.png'
        },
        'pumpkin' => {
          image: 'https://minecraft.wiki/images/Carved_Pumpkin_(N)_JE5.png'
        },
        'jack_o_lantern' => {
          image: 'https://minecraft.wiki/images/Jack_o\'Lantern_(S)_JE4.png'
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
        'player_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/player_changes'
        },
        'vehicle_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/vehicle_changes'
        },
        'item_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/item_changes'
        },
        'block_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/block_changes'
        },
        'entity_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/entity_changes'
        }
      }
  
      def initialize(tag_name, text, tokens)
        super
        @params = text.split(',').map(&:strip)
      end
  
      def render(context)
        id = @params[0]
        link_text = @params[1]
  
        tag_data = MAPPINGS[id]

        # Just text if no mapping
        if (!tag_data)
          return %Q{<span class="mc-gold">#{link_text}</span>&nbsp;<span class="mc-red">[🛠️]</span>}
        end
  
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
  