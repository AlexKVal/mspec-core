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

      argv + @submitted_options[:files_or_directories_to_run]
    end

    private
      def add_full_descriptions(argv)
        if @submitted_options[:full_description]
          argv << '--example' << @submitted_options[:full_description].source.delete('\\')
        end
      end
  end
end
