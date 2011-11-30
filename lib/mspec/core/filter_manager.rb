module MSpec
  module Core
    class FilterManager
      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions, @exclusions = {}, {}
      end

      def include(*args)
        update(@inclusions, @exclusions, *args)
      end

      def exclude(*args)
        update(@exclusions, @inclusions, *args)
      end

      def update(orig, opposite, *updates)
        puts "orig: " + orig.inspect
        puts "opposite: " + opposite.inspect
        puts "updates: " + updates.inspect

        if updates.first == :weak
          updated = updates.last.merge(orig)
          opposite.each_key {|k| updated.delete(k)}
          orig.replace(updated)
        else
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end
        puts "orig: " + orig.inspect
      end
    end
  end
end
