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
        wiki_url = context.registers[:site].config['url'] + tag_data[:url]
        current_url = context.environments.first['page']['url'] || context.environments.first['page']['permalink']
  
        # No link if current page is the same
        if current_url == tag_data[:url]
            return %Q{<img src="#{image_src}" alt="#{link_text}" draggable="false"> <span class="mc-gold">#{link_text}</span>}
        end

        %Q{<img src="#{image_src}" alt="#{link_text}" draggable="false"> <a href="#{wiki_url}" class="wiki-link mc-gold">#{link_text}</a>}
      end
    end
  end
  
  Liquid::Template.register_tag('symlink', Jekyll::SymlinkTag)
  