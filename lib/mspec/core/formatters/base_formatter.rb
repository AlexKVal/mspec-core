require 'mspec/core/formatters/helpers'
require 'stringio'

module MSpec
  module Core
    module Formatters

      class BaseFormatter
        include Helpers
        attr_reader :output

        def initialize(output)
          @output = output || StringIO.new
        end
      end

    end
  end
end
