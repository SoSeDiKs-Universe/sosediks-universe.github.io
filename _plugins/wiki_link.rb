module Jekyll
  class WikiLinkTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end

    def render(context)
      current_lang = context.registers[:site].config['active_lang'] || context.registers[:page]['lang']

      link_base = case current_lang
                    when 'ru'
                      "https://minecraft.wiki/w/#{@text}"
                    when 'uk'
                      "https://uk.minecraft.wiki/w/#{@text}"
                    else # Default to English
                      "https://minecraft.wiki/w/#{@text}"
                    end

      link_text = case current_lang
                    when 'ru'
                      '[Вики]'
                    when 'uk'
                      '[Вікі]'
                    else
                      '[Wiki]'
                    end

      %Q{<a href="#{link_base}" class="wiki-link mc-dark-gray" target="_blank">#{link_text}</a>}
    end
  end
end

# Register the custom tag with the name 'wiki_link'
Liquid::Template.register_tag('wiki_link', Jekyll::WikiLinkTag)
