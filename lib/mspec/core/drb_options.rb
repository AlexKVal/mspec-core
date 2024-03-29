# Builds command line arguments to pass to the mspec command over DRb

module MSpec::Core
  class DrbOptions
    def initialize(submitted_options, filter_manager)
      @submitted_options = submitted_options
      @filter_manager    = filter_manager
    end

    def options
      argv = []
      argv << '--color'     if @submitted_options[:color]
      argv << "--profile"   if @submitted_options[:profile_examples]
      argv << "--backtrace" if @submitted_options[:full_backtrace]
      argv << "--tty"       if @submitted_options[:tty]
      argv << '--fail-fast' if @submitted_options[:fail_fast]
      argv << '--options'   << @submitted_options[:custom_options_file] if @submitted_options[:custom_options_file]
      argv << '--order'     << @submitted_options[:order] if @submitted_options[:order]

      add_full_descriptions(argv)
      add_failure_exit_code(argv)
      add_line_numbers(argv)
      add_filter(argv, :inclusion, @filter_manager.inclusions)
      add_filter(argv, :exclusion, @filter_manager.exclusions)
      add_formatters(argv)
      add_libs(argv)
      add_requires(argv)

      argv + @submitted_options[:files_or_directories_to_run]
    end

    private
      def add_full_descriptions(argv)
        if @submitted_options[:full_description]
          argv << '--example' << @submitted_options[:full_description].source.delete('\\')
        end
      end

      def add_failure_exit_code(argv)
        if @submitted_options[:failure_exit_code]
          argv << '--failure-exit-code' << @submitted_options[:failure_exit_code].to_s
        end
      end

      def add_line_numbers(argv)
        @submitted_options[:line_numbers].each do |num|
          argv << '--line_number' << num
        end if @submitted_options[:line_numbers]
        # RSpec's code
        # argv.push(*@submitted_options[:line_numbers].inject([]){|a,l| a << "--line_number" << l})
      end

      def add_formatters(argv)
        @submitted_options[:formatters].each do |pare|
          argv << '--format' << pare[0]
          argv << '--out'    << pare[1] if pare[1]
        end if @submitted_options[:formatters]
      end

      def add_filter(argv, name, hash)
        hash.each_pair do |k, v|
          next if [:if,:unless].include?(k)
          tag = name == :inclusion ? k.to_s : "~#{k}"
          tag << ":#{v}" if v.is_a?(String)
          argv << "--tag" << tag
        end unless hash.empty?
      end

      def add_libs(argv)
        @submitted_options[:libs].each do |path|
          argv << "-I" << path
        end if @submitted_options[:libs]
      end

      def add_requires(argv)
        @submitted_options[:requires].each do |path|
          argv << "--require" << path
        end if @submitted_options[:requires]
      end
  end
end
