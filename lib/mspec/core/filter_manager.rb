module MSpec
  module Core
    class FilterManager
      DEFAULT_EXCLUSIONS = {
        :if     => lambda { |value, metadata| metadata.has_key?(:if) && !value },
        :unless => lambda { |value| value }
      }

      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      module Describable
        PROC_HEX_NUMBER = /0x[0-9a-f]+@/
        PROJECT_DIR = File.expand_path('.')

        def description
          reject { |k, v| MSpec::Core::FilterManager::DEFAULT_EXCLUSIONS[k] == v }.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
        end

        def empty_without_conditional_filters?
          reject { |k, v| MSpec::Core::FilterManager::DEFAULT_EXCLUSIONS[k] == v }.empty?
        end
      end

      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions = DEFAULT_EXCLUSIONS.dup.extend(Describable)
        @inclusions = {}.extend(Describable)
      end

      def add_location(file_path, line_numbers)
        # filter_locations is a hash of expanded paths to arrays of line
        # numbers to match against. e.g.
        #   { "path/to/file.rb" => [37, 42] }
        filter_locations = @inclusions[:locations] ||= Hash.new {|h,k| h[k] = []}
        filter_locations[File.expand_path(file_path)].push(*line_numbers)
        @exclusions.clear
        @inclusions.replace(:locations => filter_locations)
      end

      def prune(examples)
        examples.select {|e| !exclude?(e) && include?(e)}
      end

      def include(*args)
        unless_standalone(*args) { merge(@inclusions, @exclusions, *args) }
      end

      def include!(*args)
        unless_standalone(*args) { replace(@inclusions, @exclusions, *args) }
      end

      def include?(example)
        @inclusions.empty? ? true : example.any_apply?(@inclusions)
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

      def exclude?(example)
        @exclusions.empty? ? false : example.any_apply?(@exclusions)
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
