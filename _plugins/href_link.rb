module Jekyll
  class HrefLinkTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @params = text.split('|').map(&:strip)
    end

    def render(context)
      return '' if @params.length != 2

      emoji = @params[0]
      title = @params[1]

      ref = title.downcase.strip
                .gsub(' ', '-')                 # Replace spaces with hyphens
                .gsub(/[^[:alnum:]\p{L}-]/, '') # Remove all non-alphanumeric characters except hyphens and letters

      %Q{<a href="#-#{ref}" class="href-link">#{emoji}</a> #{title}}
    end
  end
end

Liquid::Template.register_tag('href_link', Jekyll::HrefLinkTag)
