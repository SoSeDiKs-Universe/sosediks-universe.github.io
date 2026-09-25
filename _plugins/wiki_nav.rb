require 'cgi'
require 'json'

# Table of contents for the sidebar, and the search index, both built from the rendered wiki pages
module Jekyll
  module WikiNav
    HEADING = %r{<h([1-6])[^>]*?\sid="([^"]+)"[^>]*>(.*?)</h\1>}m

    BLOCK_TAG = %r{</?(?:p|br|li|ul|ol|div|h[1-6]|blockquote|table|tr|td|th|pre|hr|details|summary)\b[^>]*>}

    # Text of the HTML: inline tags vanish, block tags separate words
    def self.plain_text(html)
      text = html.gsub(%r{<(script|style|svg)\b.*?</\1>}m, ' ').gsub(BLOCK_TAG, ' ').gsub(/<[^>]+>/, '')
      CGI.unescapeHTML(text).gsub(/\s+/, ' ').strip
    end

    # [[level, id, text], ...] of the headings with an ID
    def self.headings(html)
      html.scan(HEADING).map { |level, id, inner| [level.to_i, id, plain_text(inner)] }
    end

    # Page content split into sections, one per heading (the text before the first heading has no anchor)
    def self.sections(html)
      parts = html.split(HEADING)
      sections = [{ level: 0, id: '', title: '', text: plain_text(parts.shift) }]
      parts.each_slice(4) do |level, id, inner, body|
        sections << { level: level.to_i, id: id, title: plain_text(inner), text: plain_text(body.to_s) }
      end
      sections
    end

    # Two top heading levels, as [[id, text, [[id, text], ...]], ...].
    # A lone top heading is just the page's title, so the levels below it are used instead
    def self.toc(html)
      items = headings(html)
      levels = items.map(&:first).uniq.sort
      levels.shift if levels.size > 1 && items.count { |level, _, _| level == levels.first } == 1
      top, sub = levels

      toc = []
      items.each do |level, id, text|
        if level == top || (level == sub && toc.empty?)
          toc << [id, text, []]
        elsif level == sub
          toc.last[2] << [id, text]
        end
      end
      toc
    end

    def self.toc_link(base, id, text)
      %(<a href="#{CGI.escapeHTML("#{base}##{id}")}">#{CGI.escapeHTML(text)}</a>)
    end

    # Sections with subsections become collapsible groups, closed by default
    def self.toc_html(toc, base)
      items = toc.map do |id, text, subs|
        next "<li>#{toc_link(base, id, text)}</li>" if subs.empty?

        sub_items = subs.map { |sub_id, sub_text| "<li>#{toc_link(base, sub_id, sub_text)}</li>" }.join
        %(<li><details class="toc-group"><summary>#{toc_link(base, id, text)}</summary><ul>#{sub_items}</ul></details></li>)
      end
      %(<ul class="toc">#{items.join}</ul>)
    end

    # The page's content, without the layout around it
    def self.content(output)
      output[%r{<div class="content">(.*)</div>\s*</body>}m, 1]
    end

    # Sidebar links marked with data-toc get their page's table of contents:
    # open for the current page (unless collapsed before), closed for the others
    NAV_LINK = %r{<a href="([^"]*)"( aria-current="page")? data-toc>(.*?)</a>}m

    Jekyll::Hooks.register :site, :post_render do |site|
      lang = site.config['active_lang'] || site.config['default_lang']
      prefix = lang == site.config['default_lang'] ? '' : "/#{lang}"
      pages = site.pages.select { |page| page.data['layout'] == 'wiki' && page.output }
      tocs = pages.to_h { |page| [page.url, toc(content(page.output).to_s)] }

      pages.each do |page|
        page.output = page.output.gsub(NAV_LINK) do
          href, current_attr, label = Regexp.last_match.captures
          # Polyglot may have already localized the link
          url = prefix.empty? ? href : href.sub(%r{\A#{Regexp.escape(prefix)}(?=/|\z)}, '')
          current = !current_attr.nil?
          link = %(<a href="#{prefix}#{url}"#{current_attr}>#{label}</a>)
          toc = tocs[url].to_a
          next link if toc.empty?

          details = %(<details class="nav-page"#{' open' if current}><summary>#{link}</summary>#{toc_html(toc, current ? '' : prefix + url)}</details>)
          next details unless current

          details + '<script>try { if (localStorage.getItem("wiki-toc-open") === "false") document.currentScript.previousElementSibling.open = false; } catch (e) {}</script>'
        end
      end
    end

    # Search index of the active language's wiki pages, next to its output
    Jekyll::Hooks.register :site, :post_write do |site|
      lang = site.config['active_lang'] || site.config['default_lang']
      prefix = lang == site.config['default_lang'] ? '' : "/#{lang}"
      pages = []
      entries = []

      site.pages.each do |page|
        next unless page.data['layout'] == 'wiki' && page.output
        next if page.data['noindex'] || page.data['search'] == false
        next if page.data['lang'] && page.data['lang'] != lang

        content = content(page.output)
        next unless content

        pages << { t: page.data['title'], u: prefix + page.url.sub(%r{/index\.html\z}, '') }
        sections(content).each do |section|
          next if section[:title].empty? && section[:text].empty?

          entries << { p: pages.size - 1, h: section[:title], a: section[:id], x: section[:text] }
        end
      end

      File.write(File.join(site.dest, 'search-index.json'), JSON.generate({ pages: pages, entries: entries }))
    end
  end
end

