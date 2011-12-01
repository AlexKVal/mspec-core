module MSpec::Core
  class Metadata < Hash
    def initialize
      self[:example_group] = {}
      @user_metadata = {}
    end

    def process(*args)
      @user_metadata = args.last if args.last.is_a? Hash
      @example_name = args.first if args.first.is_a? String

      ensure_valid_keys(@user_metadata)
      self[:example_group][:location] = @user_metadata[:caller].first if @user_metadata.has_key? :caller

      #puts "args[1][:caller]: " + args[1][:caller].inspect #remove

      self
    end

    def for_example(description, user_metadata)
      self[:description] = description
      self
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
          if user_metadata.has_key? key
            raise <<-EOM
#{"*"*50}
:#{key} is not allowed

MSpec reserves some hash keys for its own internal use,
including :#{key}, which is used on:

  #{caller(0)[4]}.

Here are all of MSpec's reserved hash keys:

  #{RESERVED_KEYS.join("\n  ")}
#{"*"*50}
EOM
          end
        end
      end
  end
end
