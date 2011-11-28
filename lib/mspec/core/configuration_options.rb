module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def configure(config)
      config.filter_manager = filter_manager

      config.force(:color => true) if options[:color]
      config.force(:default_path => options[:default_path]) if options[:default_path]
      config.force(:pattern => options[:pattern]) if options[:pattern]

      order(options.keys, :libs, :requires).each do |key|
        config.send("#{key}=", options[key])
      end

      config.add_formatter
    end

    def parse_options
      # if @args
      #   options[:files_or_directories_to_run] = @args
      # else
      #   options[:files_or_directories_to_run] = [] unless File.directory?("spec")
      # end
      
      @options ||= extract_filters_from(*all_configs).inject do |merged, pending|
        merged.merge(pending)
      end
    end

    def filter_manger
      @filter_manger ||= Filter.Manager.new
    end

    private
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
        global_options_file
        {}
      end

      def command_line_options
        @command_line_options ||= Parser.parse!(@args).merge :files_or_directories_to_run => @args
      end

      def env_options
        {}
      end

      def global_options_file
        begin
          File.join(File.expand_path("~"), ".rspec")
        rescue ArgumentError
          warn "Unable to find ~/.rspec because the HOME environment variable is not set"
          nil
        end
      end
  end
end
