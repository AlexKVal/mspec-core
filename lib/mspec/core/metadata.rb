module MSpec::Core
  class Metadata < Hash
    def initialize
      self[:example_group] = {}
    end
    def process(*args)
      RESERVED_KEYS.each do |key|
        raise ArgumentError.new(":#{key} is not allowed") if args[1].has_key? key
      end

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
  end
end
