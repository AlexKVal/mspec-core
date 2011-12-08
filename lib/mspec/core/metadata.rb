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
  end
end
