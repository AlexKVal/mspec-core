module MSpec::Core
  class Configuration
    class MustBeConfiguredBeforeExampleGroupsError < StandardError; end

    attr_accessor :treat_symbols_as_metadata_keys_with_true_values
    attr_accessor :filter_manager
    attr_accessor :files_or_directories_to_run
    attr_accessor :failure_exit_code
    attr_accessor :pattern
    attr_accessor :default_path
    attr_accessor :drb
    attr_accessor :drb_port
    attr_accessor :order
    attr_accessor :profile_examples
    attr_accessor :tty
    attr_accessor :files_to_run

    def load(file)
      #
    end

    def load_spec_files
      raise_if_rspec_1_is_loaded
      files_to_run.each do |file|
        load file
      end
    end

    def inclusion_filter
      filter_manager.inclusions
    end

    def exclusion_filter
      filter_manager.exclusions
    end

    def full_backtrace=(flag)

    end

    def add_formatter
    end

    private

      # def get_files_to_run(paths)
      # def gather_directories(path, patterns)
      # def extract_location(path)
      # def command
      # def value_for(key, default=nil)
      # def assert_no_example_groups_defined(config_option)

      def raise_if_rspec_1_is_loaded
        if defined?(Spec) && defined?(Spec::VERSION::MAJOR) && Spec::VERSION::MAJOR == 1
          raise "

#{'*'*80}
  You are running mspec, but it seems as though rspec-1 has been loaded as
  well.  This is likely due to a statement like this somewhere in the specs:

      require 'spec'

  Please locate that statement, remove it, and try again.
#{'*'*80}"
        end
      end

      # def output_to_tty?
      # def built_in_formatter(key)
      # def custom_formatter(formatter_ref)

      def string_const?(str)
        str.is_a?(String) && /\A[A-Z][a-zA-Z0-9_:]*\z/ =~ str
      end

      # def path_for(const_ref)
      # def underscore_with_fix_for_non_standard_rspec_naming(string)
      # # activesupport/lib/active_support/inflector/methods.rb, line 48
      # def underscore(camel_cased_word)
      # def file_at(path)

  end
end
