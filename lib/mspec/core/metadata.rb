module MSpec::Core
  class Metadata < Hash
    attr_writer :for_group
    def for_group?
      @for_group
    end

    def initialize(parent_group_metadata=nil)
      if parent_group_metadata
        update(parent_group_metadata)
        store(:example_group, {:example_group => parent_group_metadata[:example_group]})
      else
        store(:example_group, {})
      end

      yield self if block_given?
    end

    def process(*args)
      user_metadata = args.last.is_a?(Hash) ? args.pop : {}
      ensure_valid_keys(user_metadata)

      self[:example_group] = Metadata.new
      self[:example_group][:description_args] = args
      self[:example_group][:caller] = user_metadata.delete(:caller) || caller

      for_group = true

      update(user_metadata) # ExampleGroup additional hash user metadata
    end

    def for_example(description, user_metadata)
      store(:description_args, [description])
      store(:caller, user_metadata.delete(:caller) || caller)


      store(:execution_result, {})

      for_group = false

      update(user_metadata)
      dup
    end

    def [](key)
      return super if has_key?(key)

      case key
      when :location
        store(:location, "#{self[:file_path]}:#{self[:line_number]}")
      when :description
        store(:description, build_description_from(*self[:description_args]))
      when :full_description
        store(:full_description, full_description_for(self))
      when :file_path, :line_number
        first_caller_from_outside_rspec =~ /(.+?):(\d+)/
        store(:file_path, $1)
        store(:line_number, $2.to_i)
        super
      else
        super
      end
    end

    private
      def first_caller_from_outside_rspec
        self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
      end

      def build_description_from(*parts)
        parts.map {|p| p.to_s}.inject do |desc, p|
          p =~ /^(#|::|\.)/ ? "#{desc}#{p}".strip : "#{desc} #{p}".strip
        end || ""
      end

      def full_description_for(metadata)
        if metadata.for_group?
          build_description_from(*ancestors.reverse.map {|a| a[:description_args]}.flatten)
        else
          build_description_from(self[:example_group][:full_description], *self[:description_args])
        end
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

      RESERVED_KEYS = [
        :description_args,
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
          if user_metadata.has_key? key
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
