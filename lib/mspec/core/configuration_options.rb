module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def configure(config)
      config.filter_manager = filter_manager

      order(options.keys, :libs, :requires).each do |key|
        if force?(key)
          config.force(key => options[key])
        else
          config.send("#{key}=", options[key])
        end
      end

      config.add_formatter
    end

    def parse_options
      @options ||= extract_filters_from(*all_configs).inject do |merged, pending|
        merged.merge(pending)
      end
      puts "@options: " + @options.inspect # remove
      @options
    end

    def filter_manager
      @filter_manager ||= FilterManager.new
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
        puts "@all_configs: " + @all_configs.inspect # remove
        @all_configs
      end

      def file_options
        if custom_options_file
          [options_from_file( custom_options_file )]
        else
          [options_from_file( global_options_file ).merge( options_from_file( local_options_file ))]
        end
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
          File.join(File.expand_path("~"), ".rspec")
        rescue ArgumentError
          warn "Unable to find ~/.rspec because the HOME environment variable is not set"
          nil
        end
      end

      def local_options_file
        ".rspec"
      end

      def custom_options_file
        command_line_options[:custom_options_file]
      end
  end
end
