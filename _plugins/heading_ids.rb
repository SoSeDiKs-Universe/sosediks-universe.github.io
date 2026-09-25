require 'kramdown-parser-gfm'

# Heading IDs like GitHub's, minus what emoji leave behind: the emoji itself is dropped, but its variation
# selector (and joiners) and the space after it were kept, giving IDs like "️-bottled-air" instead of "bottled-air"
module Jekyll
  module HeadingIds
    def self.slug(text)
      text.downcase
          .gsub(/[^\p{Word}\- \t]/, '')
          .delete("\uFE0E\uFE0F\u200D\u20E3")
          .tr(" \t", '-')
          .gsub(/\A-+|-+\z/, '')
    end
  end
end

module Kramdown
  module Parser
    class GFM
      def generate_gfm_header_id(text)
        result = Jekyll::HeadingIds.slug(text)
        result = 'section' if result.empty?

        @id_counter[result] += 1
        counter_result = @id_counter[result]
        result << "-#{counter_result}" if counter_result > 0

        @options[:auto_id_prefix] + result
      end
    end
  end
end
