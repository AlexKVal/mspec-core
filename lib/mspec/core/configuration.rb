module MSpec::Core
  class Configuration
    class MustBeConfiguredBeforeExampleGroupsError < StandardError; end

    def self.define_reader(name)
      eval "
        def #{name}
          value_for(#{name.inspect}, defined?(@#{name}) ? @#{name} : nil)
        end"
    end

    def self.deprecate_alias_key
      MSpec.warn_deprecation "
The :alias option to add_setting is deprecated. Use :alias_with on the original setting instead.
Called from #{caller(0)[5]}"
    end

    def self.define_aliases(name, alias_name)
      alias_method alias_name, name
      alias_method "#{alias_name}=", "#{name}="
      define_predicate_for alias_name
    end

    def self.define_predicate_for(*names)
      names.each {|name| alias_method "#{name}?", name}
    end

    def self.add_setting(name, opts={})
      raise "Use the instance add_setting method if you want to set a default" if opts.has_key?(:default)
      if opts[:alias]
        deprecate_alias_key
        define_aliases(opts[:alias], name)
      else
        attr_writer name
        define_reader name
        define_predicate_for name
      end
      [opts[:alias_with]].flatten.compact.each do |alias_name|
        define_aliases(name, alias_name)
      end
    end

    add_setting :treat_symbols_as_metadata_keys_with_true_values
    attr_accessor :filter_manager
    add_setting :failure_exit_code
    add_setting :tty
    add_setting :files_to_run

    # Load files matching this pattern (default: `'**/*_spec.rb'`)
    add_setting :pattern, :alias_with => :filename_pattern

    # Path to use if no path is provided to the `mspec` command (default:
    # `"spec"`). Allows you to just type `mspec` instead of `mspec spec` to
    # run all the examples in the `spec` directory.
    add_setting :default_path

    # Run examples over DRb (default: `false`). MSpec doesn't supply the DRb
    # server, but you can use tools like spork.
    add_setting :drb

    # The drb_port (default: `8989`).
    add_setting :drb_port

    # Determines the order in which examples are run (default: OS standard
    # load order for files, declaration order for groups and examples).
    add_setting :order

    # Report the times for the 10 slowest examples (default: `false`).
    add_setting :profile_examples


    def initialize
      #@expectation_frameworks = []
      #@include_or_extend_modules = []
      #@mock_framework = nil
      @files_to_run = []
      #@formatters = []
      #@color = false
      #@pattern = '**/*_spec.rb'
      #@failure_exit_code = 1
      #@backtrace_clean_patterns = DEFAULT_BACKTRACE_PATTERNS.dup
      #@default_path = 'spec'
      #@filter_manager = FilterManager.new
      @preferred_options = {}
      #@seed = srand % 0xFFFF
    end

    def load_spec_files
      files_to_run.map {|f| load File.expand_path(f) }
      raise_if_rspec_1_is_loaded
    end

    def inclusion_filter
      filter_manager.inclusions
    end

    def exclusion_filter
      filter_manager.exclusions
    end

    def full_backtrace=(flag)
      #
    end

    def add_formatter
    end

    def files_or_directories_to_run=(*files)
      #
    end

    private

      # def get_files_to_run(paths)
      # def gather_directories(path, patterns)
      # def extract_location(path)
      # def command

      def value_for(key, default=nil)
        @preferred_options.has_key?(key) ? @preferred_options[key] : default
      end

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
