module MSpec::Core
  class Configuration
    attr_accessor :treat_symbols_as_metadata_keys_with_true_values
    attr_accessor :filter_manager
    attr_accessor :files_or_directories_to_run
    attr_accessor :failure_exit_code
    attr_accessor :pattern
    attr_accessor :default_path
    attr_accessor :drb
    attr_accessor :drb_port
    attr_accessor :order

    def inclusion_filter
      filter_manager.inclusions
    end

    def exclusion_filter
      filter_manager.exclusions
    end

    def add_formatter      
    end
  end
end
