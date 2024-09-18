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
        'torch' => {
          image: 'https://minecraft.wiki/images/Invicon_Torch.png'
        },
        'saddle' => {
          image: 'https://minecraft.wiki/images/Invicon_Saddle.png'
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
  