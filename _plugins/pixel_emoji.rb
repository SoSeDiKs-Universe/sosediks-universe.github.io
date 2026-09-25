require 'json'
require 'cgi'

# Emoji drawn as Minecraft pixel art, using PixelTwemojiMC-9 (https://github.com/AmberWat/PixelTwemojiMC-9):
# every emoji in the pages' text becomes a sprite from its sheets, with the emoji itself kept as invisible text
# inside it for copying, searching and screen readers. _emoji holds the pack's font and its remappings of
# emoji sequences, assets/emoji its sheets; all taken from the server's resource pack (datasets/emoji),
# which has newer emoji than the GitHub release
module Jekyll
  module PixelEmoji
    DIR = File.expand_path('../_emoji', __dir__)
    SHEETS = { 'twemoji:font/emoji.png' => 'e', 'twemoji:font/flags.png' => 'f' }.freeze
    VS16 = "️".freeze

    # Sheet cells of the emoji, as {emoji without VS16 => [sheet, column, row]}
    def self.cells
      @cells ||= begin
        glyphs = {}
        JSON.parse(File.read(File.join(DIR, 'font.json')))['providers'].each do |provider|
          sheet = SHEETS[provider['file']] or next
          provider['chars'].each_with_index do |row, y|
            row.each_char.with_index { |char, x| glyphs[char] = [sheet, x, y] unless char == "\0" || char == ' ' }
          end
        end

        # Sequences use private-use characters, which aren't emoji themselves
        cells = {}
        JSON.parse(File.read(File.join(DIR, 'remappings.json'))).each do |sequence, char|
          cells[sequence.delete(VS16)] = glyphs[char] if glyphs[char]
        end
        glyphs.each { |char, cell| cells[char] ||= cell if char.ord < 0xF0000 }
        cells
      end
    end

    # Longest emoji first. VS16 is optional, except after characters shown as text by default (like © or ↔)
    def self.pattern
      @pattern ||= begin
        alternatives = cells.keys.sort_by { |emoji| -emoji.length }.map do |emoji|
          if emoji.length == 1 && !emoji.match?(/\p{Emoji_Presentation}/)
            Regexp.escape(emoji) + VS16
          else
            emoji.each_char.map { |char| Regexp.escape(char) + "#{VS16}?" }.join
          end
        end
        Regexp.new(alternatives.join('|'))
      end
    end

    def self.cell(emoji)
      cells[emoji.delete(VS16)]
    end

    def self.span(emoji)
      sheet, x, y = cell(emoji)
      %(<span class="emoji emoji-#{sheet}" style="--x:#{x};--y:#{y}">#{emoji}</span>)
    end

    # The found emoji with their cells, for the script to draw them the same way
    def self.used(text, found = {})
      text.scan(pattern) { |emoji| found[emoji] = cell(emoji) }
      found
    end

    # Text, and the markup around it that is left as is: the head, scripts and styles, comments,
    # and tags with their attributes
    CHUNK = %r{<head\b.*?</head>|<(script|style|textarea)\b.*?</\1>|<!--.*?-->|<[^>]*>|[^<]+}m
    TOOLTIP_ATTRIBUTE = /\sdata-(?:tooltip|tooltip-note|cycle-names)="([^"]*)"/

    def self.render(html)
      out = html.gsub(CHUNK) do |chunk|
        chunk.start_with?('<') ? chunk : chunk.gsub(pattern) { |emoji| span(emoji) }
      end

      # Tooltips are made by wiki.js, which draws their emoji from this map
      found = {}
      html.scan(TOOLTIP_ATTRIBUTE) { |value,| used(CGI.unescapeHTML(value), found) }
      return out if found.empty?

      out.sub(%r{</body>}) { %(<script type="application/json" id="emoji-map">#{JSON.generate(found)}</script></body>) }
    end

    # After the tables of contents are built, so theirs get drawn too
    Jekyll::Hooks.register :site, :post_render, priority: :low do |site|
      site.pages.each do |page|
        next unless page.output&.include?('mc-font.css')

        page.output = render(page.output)
      end
    end
  end
end
