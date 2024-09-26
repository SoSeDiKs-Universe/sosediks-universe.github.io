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
        # Items
        'bucket' => {
          image: 'https://minecraft.wiki/images/Invicon_Bucket.png'
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
        'oak_door' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Door.png'
        },
        'oak_trapdoor' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Trapdoor.png'
        },
        'oak_button' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Button.png'
        },
        'oak_sign' => {
          image: 'https://minecraft.wiki/images/Invicon_Oak_Sign.png'
        },
        'magma_block' => {
          image: 'https://minecraft.wiki/images/Invicon_Magma_Block.gif'
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
        'block_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/block_changes'
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
  