module Jekyll
  # Description of a page for search engines and link previews: its first paragraphs of text,
  # enough of them to say something, cut at a word to fit
  module PageDescription
    def page_description(html, min = 120, max = 200)
      text = +''
      html.to_s.scan(%r{<p\b[^>]*>(.*?)</p>}m) do |inner,|
        # Emoji are icons here, which don't read well in plain text
        paragraph = WikiNav.plain_text(inner).gsub(PixelEmoji.pattern, ' ').gsub(/\s+/, ' ').strip
        next if paragraph.empty?

        text << ' ' unless text.empty?
        text << paragraph
        break if text.length >= min
      end
      # A sentence introducing what follows (e.g. a list) makes no sense on its own
      text = text.sub(/(?<=[.!?])\s[^.!?]*:\z/, '') if text.end_with?(':')
      return text if text.length <= max

      cut = text[0, max - 1]
      cut = cut[0, cut.rindex(' ')] if cut.rindex(' ')
      "#{cut.sub(/[\s,.;:—–-]+\z/, '')}…"
    end
  end
end

Liquid::Template.register_filter(Jekyll::PageDescription)
