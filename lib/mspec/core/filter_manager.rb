module MSpec
  module Core
    class FilterManager
      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions = @exclusions = {}
      end

      def include(*args)
        update(@exclusions, @inclusions, *args)
      end

      def exclude(*args)
        update(@inclusions, @exclusions, *args)
      end

      def update(target, opposites, *updates)
        target.merge!(updates.last).each_key {|k| opposites.delete(k)}
      end
    end
  end
end
