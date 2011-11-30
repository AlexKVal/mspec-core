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
      end

      def add_formatters(argv)
        @submitted_options[:formatters].each do |pare|
          argv << '--format' << pare[0]
          argv << '--out'    << pare[1] if pare[1]
        end if @submitted_options[:formatters]
      end

      def add_filter(argv, name, hash)
        #puts "name: " + name.inspect
        #puts "hash: " + hash.inspect
        hash.each_key do |key|
          argv << '--tag' << "#{'~' if name == :exclusion}#{key}:#{hash[key]}"
          #puts "argv: " + argv.inspect
        end unless hash.empty?
      end
  end
end
