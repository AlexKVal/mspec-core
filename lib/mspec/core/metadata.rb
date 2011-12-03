module MSpec::Core
  class Metadata < Hash

    module MetadataHash
      def [](key)
        return super if has_key?(key)
        # case key
        # when "1"
        # when "2"
        # end
      end

      private
        # def first_caller_from_outside_rspec
        #   self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
        # end
    end

    def initialize(parent_group_metadata=nil)
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
      store(:description, description)
      store(:full_description, "#{@group_description} #{description}")
      store(:execution_result, {})

      store(:caller, user_metadata.delete(:caller) || caller)
      first_caller_from_outside_rspec =~ /(.+?):(\d+)/
      store(:file_path, $1)
      store(:line_number, $2.to_i)

      store(:location, "#{self[:file_path]}:#{self[:line_number]}")

      # hack
      store(:arbitrary, user_metadata.delete(:arbitrary))

      self
    end

    protected
      def configure_for_example(description, user_metadata)
        store(:description_args, [description])
        store(:caller, user_metadata.delete(:caller) || caller)
        update(user_metadata)
      end

    private
      def first_caller_from_outside_rspec
        self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
      end

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
