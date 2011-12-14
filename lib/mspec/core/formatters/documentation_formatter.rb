require 'mspec/core/formatters/base_text_formatter'

module MSpec
  module Core
    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        def initialize(output)
          super(output)
          @group_level = 0
        end
      end

    end
  end
end
