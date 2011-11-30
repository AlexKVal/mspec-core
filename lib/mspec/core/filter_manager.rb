module MSpec
  module Core
    class FilterManager
      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      attr_reader :exclusions, :inclusions

      def initialize
        @inclusions, @exclusions = {}, {}
      end

      def include(*args)
        # args.each do |arg|
        #   [:line_numbers, :locations, :full_description].includes? arg.key
        #   args.unshift :replace
        # end

        puts "#{'*'*20}"
        puts "args: " + args.inspect

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
        puts "#{'='*15}"
        puts "orig: " + orig.inspect
        puts "opposite: " + opposite.inspect
        puts "updates: " + updates.inspect

        case updates.first
        when :replace
          orig.replace(updates.last)
        when :weak # priority
          updated = updates.last.merge(orig)
          opposite.each_key {|k| updated.delete(k)}
          orig.replace(updated)
        else # strong priority
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end

        puts "orig: " + orig.inspect
      end
    end
  end
end
