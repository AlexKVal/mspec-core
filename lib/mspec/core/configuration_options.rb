module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def parse_options
      warn if ENV["HOME"].nil?

      @options ||= command_line_options
      @options[:files_or_directories_to_run] = [] unless File.directory?("spec")
    end

    def configure(config)
      config.force(:color => true) if options[:color]
      order(options.keys, :libs, :requires).each do |key|
        config.send("#{key}=", options[key])
      end
      config.add_formatter
    end

    private
      def order(keys, *ordered)
        ordered.reverse.each do |key|
          keys.unshift(key) if keys.delete(key)
        end
        keys
      end

      def command_line_options
        Parser.parse!(@args)
      end
  end
end
