module MSpec
  module Core
    class FilterManager
      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions, @exclusions = {}, {}
      end

      def include(*args)
        return if already_set_standalone_filter?

        is_standalone_filter?(args.last) ? @inclusions.replace(args.last) : update(@inclusions, @exclusions, *args)
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

      private
        def is_standalone_filter?(filter)
          STANDALONE_FILTERS.any? {|key| filter.has_key?(key)}
        end

        def already_set_standalone_filter?
          is_standalone_filter?(@inclusions)
        end
    end
  end
end
