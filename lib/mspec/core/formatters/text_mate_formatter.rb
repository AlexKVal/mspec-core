require 'cgi'
require 'mspec/core/formatters/html_formatter'

module MSpec
  module Core
    module Formatters
      # Formats backtraces so they're clickable by TextMate
      class TextMateFormatter < HtmlFormatter
      end

    end
  end
end
