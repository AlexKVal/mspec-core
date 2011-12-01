module MSpec::Core
  class Metadata < Hash
    def initialize
      self[:example_group] = {}
    end

    def process(*args)
      ensure_valid_keys(args.last)

      if args.first == 'group'
        puts "args[1][:caller]: " + args[1][:caller].inspect #remove
        
        self[:example_group][:location] = args[1][:caller].first if args[1].has_key? :caller
        
        puts "self[:example_group][:location]: " + self[:example_group][:location].inspect #remove
      end
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
