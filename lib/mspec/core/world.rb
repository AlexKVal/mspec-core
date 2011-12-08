module MSpec
  module Core
    class World
      attr_accessor :example_groups
      
      def initialize
        @example_groups = []
      end
    end
  end
end
