module Jekyll
    class SeeAlsoTagBlock < Liquid::Block
  
      def render(context)
        text = super
        "<p class=\"see_also mc-dark-gray\">#{text}</p>"
      end
  
    end
  end
  
  Liquid::Template.register_tag('see_also', Jekyll::SeeAlsoTagBlock)
