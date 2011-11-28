module MSpec::Core
  class Configuration
    attr_accessor :treat_symbols_as_metadata_keys_with_true_values
    attr_accessor :filter_manager
    attr_accessor :files_or_directories_to_run
    
    def add_formatter      
    end
  end
end
