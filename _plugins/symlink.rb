module Jekyll
    class SymlinkTag < Liquid::Tag
  
      MAPPINGS = {
        'wandering_trader' => {
          image: 'https://minecraft.wiki/images/EntitySprite_wandering-trader.png',
          url: '/wiki/entity/wandering_trader'
        },
        'player' => {
          image: 'https://minecraft.wiki/images/EntitySprite_steve.png',
          url: '/wiki/entity/player'
        },
        'llama' => {
          image: 'https://minecraft.wiki/images/EntitySprite_creamy-llama.png',
          url: '/wiki/entity/llama'
        },
        'player_changes' => {
          emoji: '⚙️',
          url: '/wiki/misc/player_changes'
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
        return %Q{<span class="mc-gold">#{link_text}</span> <span class="mc-red">[🛠️]</span>} unless tag_data
  
        image_src = tag_data[:image]
        emoji_src = tag_data[:emoji]
        wiki_url = context.registers[:site].config['url'] + tag_data[:url]
        current_url = context.environments.first['page']['url'] || context.environments.first['page']['permalink']
  
        # No link if current page is the same
        if current_url == tag_data[:url]
          if (emoji_src)
            return %Q{#{emoji_src} <span class="mc-gold">#{link_text}</span>}
          else
            return %Q{<img src="#{image_src}" alt="#{link_text}" draggable="false" class="pixelated"> <span class="mc-gold">#{link_text}</span>}
          end
        end

        if (emoji_src)
          return %Q{#{emoji_src} <a href="#{wiki_url}" class="wiki-link mc-gold">#{link_text}</a>}
        else
          return %Q{<img src="#{image_src}" alt="#{link_text}" draggable="false" class="pixelated"> <a href="#{wiki_url}" class="wiki-link mc-gold">#{link_text}</a>}
        end
      end
    end
  end
  
  Liquid::Template.register_tag('symlink', Jekyll::SymlinkTag)
  