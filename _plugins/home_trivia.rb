require 'cgi'

# Trivia for the home page: short feature descriptions picked from the wiki (a section's heading and its first
# paragraph, rendered like on the wiki), each linking to its section. The home page shows a random one,
# and hides the box without JavaScript
module Jekyll
  module HomeTrivia
    PAGES = %r{\A/wiki/(?:misc|mechanics)/}
    MAX_LENGTH = 220

    VOID_TAGS = %w[img br hr input wbr source].freeze

    # The first paragraph of the section (as HTML, icons and all), if it describes something on its own
    # and is short enough; a longer one is cut after a sentence ending outside of any markup
    def self.fact_html(body)
      paragraph = body[%r{\A\s*<p\b[^>]*>(.*?)</p>}m, 1] or return
      text = WikiNav.plain_text(paragraph)
      return if text.empty? || text.start_with?('*') || text.end_with?(':')
      return paragraph.strip if text.length <= MAX_LENGTH

      cut = nil
      depth = 0
      length = 0
      offset = 0
      paragraph.scan(/<[^>]*>|[^<]+/) do |token|
        if token.start_with?('<')
          name = token[%r{\A</?([a-z0-9]+)}i, 1].to_s.downcase
          if token.start_with?('</')
            depth -= 1
          elsif !VOID_TAGS.include?(name) && !token.end_with?('/>')
            depth += 1
          end
        else
          plain = CGI.unescapeHTML(token)
          if depth.zero?
            token.scan(/[.!?…](?=\s)/) do
              position = Regexp.last_match.end(0)
              ends_at = length + CGI.unescapeHTML(token[0, position]).length
              cut = offset + position if ends_at <= MAX_LENGTH
            end
          end
          length += plain.length
        end
        offset += token.length
      end
      cut && paragraph[0, cut].strip
    end

    def self.facts(site, prefix)
      site.pages.flat_map do |page|
        next [] unless page.data['layout'] == 'wiki' && page.output && page.url.match?(PAGES)
        next [] if page.data['noindex'] || page.url.end_with?('/credits')

        content = WikiNav.content(page.output).to_s
        page_url = "#{prefix}#{page.url}"
        sections = content.split(WikiNav::HEADING).drop(1).each_slice(4).to_a
        sections.each_with_index.filter_map do |(level, id, inner, body), i|
          # A section with subsections is a category (its text introduces them), not a feature
          next_level = sections[i + 1]&.first
          next if next_level && next_level.to_i > level.to_i

          html = fact_html(body.to_s) or next
          # Links to sections of the same page lead there from the home page too
          html = html.gsub('href="#', %(href="#{page_url}#))
          # Only the shown fact's icons get loaded
          html = html.gsub('<img ', '<img loading="lazy" ')
          { title: WikiNav.plain_text(inner), html: html, url: "#{page_url}##{id}" }
        end
      end
    end

    Jekyll::Hooks.register :site, :post_render do |site|
      home = site.pages.find { |page| page.output&.include?('<!-- trivia -->') }
      next unless home

      lang = site.config['active_lang'] || site.config['default_lang']
      prefix = lang == site.config['default_lang'] ? '' : "/#{lang}"
      facts = facts(site, prefix)
      next if facts.empty?

      items = facts.each_with_index.map do |fact, i|
        %(<li class="trivia-fact" data-url="#{CGI.escapeHTML(fact[:url])}"#{' hidden' unless i.zero?}>) +
          %(<span class="trivia-fact-title mc-gold">#{CGI.escapeHTML(fact[:title])}</span>) +
          %(<span class="mc-white">#{fact[:html]}</span></li>)
      end
      # The bulb links to the shown fact's section (observer.js follows it when another fact is shown)
      home.output = home.output
                        .sub('<!-- trivia -->', items.join)
                        .sub(%r{(<a id="trivia-link"[^>]*href=")[^"]*"}) { "#{Regexp.last_match(1)}#{CGI.escapeHTML(facts.first[:url])}\"" }
    end
  end
end
