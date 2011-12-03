module MSpec
  module Core
    class FilterManager
      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions, @exclusions = {}, {}
      end


      def include(*args)
        unless_standalone(*args) { merge(@inclusions, @exclusions, *args) }
      end

      def include!(*args)
        unless_standalone(*args) { replace(@inclusions, @exclusions, *args) }
      end

      def include_with_low_priority(*args)
        unless_standalone(*args) { reverse_merge(@inclusions, @exclusions, *args) }
      end

      def exclude(*args)
        merge(@exclusions, @inclusions, *args)
      end

      def exclude!(*args)
        replace(@exclusions, @inclusions, *args)
      end

      def exclude_with_low_priority(*args)
        reverse_merge(@exclusions, @inclusions, *args)
      end

      private
        def unless_standalone(*args)
          is_standalone_filter?(args.last) ? @inclusions.replace(args.last) : yield unless already_set_standalone_filter?
        end

        def merge(orig, opposite, *updates)
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end

        def replace(orig, opposite, *updates)
          updates.last.each_key {|k| opposite.delete(k)}
          orig.replace(updates.last)
        end

        def reverse_merge(orig, opposite, *updates)
          updated = updates.last.merge(orig)
          opposite.each_pair {|k,v| updated.delete(k) if updated[k] == v}
          orig.replace(updated)
        end

        def is_standalone_filter?(filter)
          STANDALONE_FILTERS.any? {|key| filter.has_key?(key)}
        end

        def already_set_standalone_filter?
          is_standalone_filter?(@inclusions)
        end
    end
  end
end
