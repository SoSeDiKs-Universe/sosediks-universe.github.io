module Jekyll
    class SideNoteTagBlock < Liquid::Block
  
      def render(context)
        text = super
        "<p class=\"side-note mc-dark-gray\">#{text}</p>"
      end
  
    end
  end
  
  Liquid::Template.register_tag('side_note', Jekyll::SideNoteTagBlock)
