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
      argv << '--fail-fast' if @submitted_options[:fail_fast]
      argv << '--options'   if @submitted_options[:custom_options_file]
      argv << @submitted_options[:custom_options_file] if @submitted_options[:custom_options_file]
      argv << '--order'     if @submitted_options[:order]
      argv << @submitted_options[:order] if @submitted_options[:order]
      return argv unless @submitted_options.delete(:drb)
      argv + @submitted_options.delete(:files_or_directories_to_run)
    end
  end
end
