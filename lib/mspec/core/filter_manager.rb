module MSpec
  module Core
    class FilterManager
      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions = @exclusions = {}
      end

      def include(*args)
        update(@inclusions, @exclusions, *args)
      end

      def exclude(*args)
        update(@exclusions, @inclusions, *args)
      end

      def update(orig, opposite, *updates)
        updated = updates.last.merge(orig)
        opposite.each_key {|k| updated.delete(k)}
        orig.replace(updated)
      end
    end
  end
end
