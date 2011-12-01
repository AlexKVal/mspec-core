module MSpec::Core
  class Metadata < Hash
    def initialize
      @group_description = ''
      self[:example_group] = {}
      @user_metadata = {}
    end

    def process(*args)
      @user_metadata = args.last if args.last.is_a? Hash
      @group_description = args.first if args.first.is_a? String

      ensure_valid_keys(@user_metadata)
      self[:example_group][:location] = @user_metadata[:caller].first if @user_metadata.has_key? :caller

      #puts "args[1][:caller]: " + args[1][:caller].inspect #remove

      self
    end

    def for_example(description, user_metadata)
      self[:description] = description
      self[:full_description] = "#{@group_description} #{description}"
      self[:execution_result] = {}

      self[:caller] = user_metadata.has_key?(:caller) ? user_metadata[:caller] : caller
      first_caller_from_outside_rspec =~ /(.+?):(\d+)/
      self[:file_path], self[:line_number] = [$1, $2.to_i]

      self[:location] = "#{self[:file_path]}:#{self[:line_number]}"

      # hack
      self[:arbitrary] = user_metadata[:arbitrary] if user_metadata.has_key?(:arbitrary)

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

      def first_caller_from_outside_rspec
        self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
      end

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
