module MSpec
  module Core
    class FilterManager
      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions, @exclusions = {}, {}
      end

      def include(*args)
        hash_arg = args.first.is_a?(Hash) ? args.first : args.last
        args.unshift :replace if STANDALONE_FILTERS.any? do |name|
          hash_arg.has_key? name
        end

        update(@inclusions, @exclusions, *args)
      end

      def exclude(*args)
        update(@exclusions, @inclusions, *args)
      end

      def update(orig, opposite, *updates)
        case updates.first
        when :replace
          orig.replace(updates.last)
        when :low_priority
          updated = updates.last.merge(orig)
          opposite.each_key {|k| updated.delete(k)}
          orig.replace(updated)
        else
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end
      end
    end
  end
end
