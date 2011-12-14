module MSpec
  module Core
    class World
      attr_accessor :example_groups

      def initialize
        @example_groups = []
      end

      def preceding_declaration_line(filter_line)
        # declaration_line_numbers.sort.inject(nil) do |highest_prior_declaration_line, line|
        #   line <= filter_line ? line : highest_prior_declaration_line
        # end
      end

    end
  end
end
