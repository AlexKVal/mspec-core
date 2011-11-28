module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def parse_options
      warn if ENV["HOME"].nil?

      @options ||= command_line_options

      if @args
        options[:files_or_directories_to_run] = @args
      else
        options[:files_or_directories_to_run] = [] unless File.directory?("spec")
      end
    end

    def configure(config)
      config.force(:color => true) if options[:color]
      config.force(:default_path => options[:default_path]) if options[:default_path]
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
