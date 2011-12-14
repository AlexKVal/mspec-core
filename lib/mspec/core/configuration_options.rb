module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def configure(config)
      formatters = options.delete(:formatters)

      config.filter_manager = filter_manager

      order(options.keys, :libs, :requires).each do |key|
        if force?(key)
          config.force(key => options[key])
        else
          config.send("#{key}=", options[key])
        end
      end

      formatters.each {|pair| config.add_formatter(*pair) } if formatters
    end

    def parse_options
      @options ||= extract_filters_from(*all_configs).inject do |merged, pending|
        merged.merge(pending)
      end
    end

    def filter_manager
      @filter_manager ||= FilterManager.new
    end

    def drb_argv
      DrbOptions.new(options, filter_manager).options
    end

    private
      NON_FORCED_OPTIONS = [:debug, :requires, :libs, :files_or_directories_to_run, :line_numbers, :full_description]

      def force?(key)
        !NON_FORCED_OPTIONS.include?(key)
      end

      def order(keys, *ordered)
        ordered.reverse.each do |key|
          keys.unshift(key) if keys.delete(key)
        end
        keys
      end

      def extract_filters_from(*configs)
        configs.compact.each do |config|
          filter_manager.include config.delete(:inclusion_filter) if config.has_key?(:inclusion_filter)
          filter_manager.exclude config.delete(:exclusion_filter) if config.has_key?(:exclusion_filter)
        end
      end

      def all_configs
        @all_configs ||= file_options << command_line_options << env_options
      end

      def file_options
        custom_options_file ? [custom_options] : [global_options, local_options]
      end

      def custom_options
        options_from_file custom_options_file
      end

      def global_options
        options_from_file global_options_file
      end

      def local_options
        options_from_file local_options_file
      end

      def command_line_options
        @command_line_options ||= Parser.parse!(@args).merge :files_or_directories_to_run => @args
      end

      def env_options
        ENV["SPEC_OPTS"] ? Parser.parse!(ENV["SPEC_OPTS"].split) : {}
      end

      def options_from_file(path)
        return {} unless path && File.exists?(path)
        Parser.parse!(File.read(path).split(/\n+/).map {|l| l.split}.flatten)
      end

      def global_options_file
        begin
          File.join(File.expand_path("~"), ".mspec")
        rescue ArgumentError
          warn "Unable to find ~/.mspec because the HOME environment variable is not set"
          nil
        end
      end

      def local_options_file
        ".mspec"
      end

      def custom_options_file
        command_line_options[:custom_options_file]
      end
  end
end
