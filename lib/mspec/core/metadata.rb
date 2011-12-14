module MSpec::Core
  class Metadata < Hash

    module MetadataHash

      def [](key)
        return super if has_key?(key)
        case key
        when :location
          store(:location, "#{self[:file_path]}:#{self[:line_number]}")
        when :file_path, :line_number
          first_caller_from_outside_mspec =~ /(.+?):(\d+)/
          store(:file_path, $1)
          store(:line_number, $2.to_i)
          super
        when :execution_result
          store(:execution_result, {})
        when :described_class
          store(:described_class, described_class)
        when :full_description
          store(:full_description, full_description)
        when :description
          store(:description, build_description_from(*self[:description_args]))
        else
          super
        end
      end

      private

        def first_caller_from_outside_mspec
          self[:caller].detect {|l| l !~ /\/lib\/mspec\/core/}
        end

        def described_class
          self[:example_group][:described_class]
        end

        def full_description
          build_description_from(self[:example_group][:full_description], *self[:description_args])
        end

        def build_description_from(*parts)
          parts.map {|p| p.to_s}.inject do |desc, p|
            p =~ /^(#|::|\.)/ ? "#{desc}#{p}" : "#{desc} #{p}"
          end || ""
        end
    end

    module ExampleMetadataHash
      include MetadataHash
    end

    module GroupMetadataHash
      include MetadataHash

      private

        def full_description
          build_description_from(*ancestors.reverse.map {|a| a[:description_args]}.flatten)
        end

        def described_class
          ancestors.each do |g|
            return g[:described_class] if g.has_key?(:described_class)
          end

          ancestors.reverse.each do |g|
            candidate = g[:description_args].first
            return candidate unless String === candidate || Symbol === candidate
          end

          nil
        end

        def ancestors
          @ancestors ||= begin
            groups = [group = self]
            while group.has_key?(:example_group)
              groups << group[:example_group]
              group = group[:example_group]
            end
            groups
          end
        end
    end

    def initialize(parent_group_metadata=nil)
      if parent_group_metadata
        update(parent_group_metadata)
        store(:example_group, {:example_group => parent_group_metadata[:example_group]}.extend(GroupMetadataHash))
      else
        store(:example_group, {}.extend(GroupMetadataHash))
      end

      yield self if block_given?
    end

    def process(*args)
      user_metadata = args.last.is_a?(Hash) ? args.pop : {}
      ensure_valid_keys(user_metadata)

      self[:example_group].store(:description_args, args)
      self[:example_group].store(:caller, user_metadata.delete(:caller) || caller)

      update(user_metadata)
    end

    def for_example(description, user_metadata)
      example_metadata = dup.extend(ExampleMetadataHash)
      example_metadata[:description_args] = [description]
      example_metadata[:caller] = user_metadata.delete(:caller) || caller
      example_metadata.update(user_metadata)
    end

    def any_apply?(filters)
      filters.any? {|k,v| filter_applies?(k,v)}
    end

    def all_apply?(filters)
      filters.all? {|k,v| filter_applies?(k,v)}
    end

    def filter_applies?(key, value, metadata=self)
      case key
      when :line_numbers
        metadata.line_number_filter_applies?(value)
      when :locations
        metadata.location_filter_applies?(value)
      else
        case value
        when Hash
          value.all? { |k, v| filter_applies?(k, v, metadata[key]) }
        when Regexp
          metadata[key] =~ value
        when Proc
          if value.arity == 2
            # Pass the metadata hash to allow the proc to check if it even has the key.
            # This is necessary for the implicit :if exclusion filter:
            #   {            } # => run the example
            #   { :if => nil } # => exclude the example
            # The value of metadata[:if] is the same in these two cases but
            # they need to be treated differently.
            value.call(metadata[key], metadata) rescue false
          else
            value.call(metadata[key]) rescue false
          end
        else
          metadata[key].to_s == value.to_s
        end
      end
    end

    def location_filter_applies?(locations)
      # it ignores location filters for other files
      line_number = example_group_declaration_line(locations)
      line_number ? line_number_filter_applies?(line_number) : true
    end

    def line_number_filter_applies?(line_numbers)
      preceding_declaration_lines = line_numbers.map {|n| MSpec.world.preceding_declaration_line(n)}
      !(relevant_line_numbers & preceding_declaration_lines).empty?
    end

    private

      RESERVED_KEYS = [
        :description,
        :example_group,
        :execution_result,
        :file_path,
        :full_description,
        :line_number,
        :location
      ]

      def ensure_valid_keys(user_metadata)
        RESERVED_KEYS.each do |key|
          if user_metadata.has_key?(key)
            raise "
#{"*"*50}
:#{key} is not allowed

MSpec reserves some hash keys for its own internal use,
including :#{key}, which is used on:

  #{caller(0)[4]}.

Here are all of MSpec's reserved hash keys:

  #{RESERVED_KEYS.join("\n  ")}
#{"*"*50}"
          end
        end
      end

      def example_group_declaration_line(locations)
        locations[File.expand_path(self[:example_group][:file_path])] if self[:example_group]
      end

      # TODO - make this a method on metadata - the problem is
      # metadata[:example_group] is not always a kind of GroupMetadataHash.
      def relevant_line_numbers(metadata=self)
        [metadata[:line_number]] + (metadata[:example_group] ? relevant_line_numbers(metadata[:example_group]) : [])
      end
  end
end
