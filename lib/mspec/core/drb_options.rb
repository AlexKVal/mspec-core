# Builds command line arguments to pass to the mspec command over DRb

module MSpec::Core
  class DrbOptions
    def initialize(submitted_options, filter_manager)
      @submitted_options = submitted_options
      @filter_manager    = filter_manager
    end

    def options
      return [] unless @submitted_options.delete(:drb)
      @options = @submitted_options.delete(:files_or_directories_to_run)
      @submitted_options.each_key {|k| @options << "--#{k.to_s}"}
      @options
    end
  end
end
