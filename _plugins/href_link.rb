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

      ref = "#{emoji} #{title}".downcase
                .gsub(/[^\p{Word}\- \t]/, '')
                .tr(" \t", '-')

      %Q{<a href="##{ref}" class="href-link">#{emoji}</a> #{title}}
    end
  end
end

Liquid::Template.register_tag('href_link', Jekyll::HrefLinkTag)
