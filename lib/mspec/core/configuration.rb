module MSpec::Core
  class Configuration
    include Hooks

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

    attr_accessor :filter_manager
    add_setting :treat_symbols_as_metadata_keys_with_true_values
    add_setting :failure_exit_code
    add_setting :tty
    add_setting :files_to_run
    add_setting :expecting_with_mspec
    add_setting :backtrace_clean_patterns

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

    # Report the times for the 10 slowest examples (default: `false`).
    add_setting :profile_examples


    def initialize
      @expectation_frameworks = []
      #@include_or_extend_modules = []
      @mock_framework = nil
      @files_to_run = []
      #@formatters = []
      #@color = false
      @pattern = '**/*_spec.rb'
      #@failure_exit_code = 1
      @backtrace_clean_patterns = DEFAULT_BACKTRACE_PATTERNS.dup
      @default_path = 'spec'
      @filter_manager = FilterManager.new
      @preferred_options = {} # #force
      #@seed = srand % 0xFFFF
    end

    def load_spec_files
      files_to_run.map {|f| load File.expand_path(f) }
      raise_if_rspec_1_is_loaded
    end

    # Returns the configured mock framework adapter module
    def mock_framework
      mock_with :mspec unless @mock_framework
      @mock_framework
    end

    def mock_framework=(framework)
      mock_with framework
    end

    def mock_with(framework)
      framework_module = case framework
      when Module
        framework
      when String, Symbol
        require 'mspec/core/mocking/with_' << case framework.to_s
        when /mspec/i
          'mspec'
        when /mocha/i
          'mocha'
        when /rr/i
          'rr'
        when /flexmock/i
          'flexmock'
        else
          'absolutely_nothing'
        end
        MSpec::Core::MockFrameworkAdapter
      end

      new_name, old_name = [framework_module, @mock_framework].map do |mod|
        mod.respond_to?(:framework_name) ?  mod.framework_name : :unnamed
      end

      unless new_name == old_name
        assert_no_example_groups_defined(:mock_framework)
      end

      @mock_framework = framework_module
    end

    def expectation_frameworks
      expect_with :mspec if @expectation_frameworks.empty?
      @expectation_frameworks
    end

    def expectation_framework=(framework)
      expect_with(framework)
    end

    def expect_with(*frameworks)
      modules = frameworks.map do |framework|
        case framework
        when :mspec
          require 'mspec/expectations'
          self.expecting_with_mspec = true
          ::MSpec::Matchers
        when :stdlib
          require 'test/unit/assertions'
          ::Test::Unit::Assertions
        else
          raise ArgumentError, "#{framework.inspect} is not supported"
        end
      end

      if (modules - @expectation_frameworks).any?
        assert_no_example_groups_defined(:expect_with)
      end

      @expectation_frameworks.clear
      @expectation_frameworks.push(*modules)
    end

    DEFAULT_BACKTRACE_PATTERNS = [
      /\/lib\d*\/ruby\//,
      /org\/jruby\//,
      /bin\//,
      /gems/,
      /spec\/spec_helper\.rb/,
      /lib\/mspec\/(core|expectations|matchers|mocks)/
    ]

    def full_backtrace=(true_or_false)
      @backtrace_clean_patterns = true_or_false ? [] : DEFAULT_BACKTRACE_PATTERNS
    end

    def cleaned_from_backtrace?(line)
      backtrace_clean_patterns.any? { |regex| line =~ regex }
    end

    def inclusion_filter
      filter_manager.inclusions
    end

    def inclusion_filter=(filter)
      filter_manager.include! build_metadata_hash_from([filter])
    end

    def exclusion_filter
      filter_manager.exclusions
    end

    def exclusion_filter=(filter)
      filter_manager.exclude! build_metadata_hash_from([filter])
    end

    def add_formatter
    end

    def files_or_directories_to_run=(*files)
      files = files.flatten
      files << default_path if command == 'mspec' && default_path && files.empty?
      self.files_to_run = get_files_to_run(files)
    end

    def filter_run_including(*args)
      filter_manager.include_with_low_priority build_metadata_hash_from(args)
    end

    alias_method :filter_run, :filter_run_including

    def filter_run_excluding(*args)
      filter_manager.exclude_with_low_priority build_metadata_hash_from(args)
    end

    # Run examples defined on `line_numbers` in all files to run.
    def line_numbers=(line_numbers)
      filter_run_including :line_numbers => line_numbers.map{|l| l.to_i}
    end

    # Seed for random ordering (default: generated randomly each run).
    define_reader :seed

    def seed=(seed)
      order_n_seed_from_seed(seed)
    end

    # Determines the order in which examples are run (default: OS standard
    # load order for files, declaration order for groups and examples).
    add_setting :order

    def order=(type)
      order_n_seed_from_order(type)
    end

    # Used to set higher priority option values from the command line.
    def force(hash)
      if hash.has_key?(:seed)
        hash[:order], hash[:seed] = order_n_seed_from_seed(hash[:seed])
      elsif hash.has_key?(:order)
        hash[:order], hash[:seed] = order_n_seed_from_order(hash[:order])
      end
      @preferred_options.merge!(hash)
    end

    private

      def get_files_to_run(paths)
        patterns = pattern.split(",")
        paths.map do |path|
          File.directory?(path) ? gather_directories(path, patterns) : extract_location(path)
        end.flatten
      end

      def gather_directories(path, patterns)
        patterns.map do |pattern|
          pattern =~ /^#{path}/ ? Dir[pattern.strip] : Dir["#{path}/{#{pattern.strip}}"]
        end
      end

      def extract_location(path)
        if path =~ /^(.*?)((?:\:\d+)+)$/
          path, lines = $1, $2[1..-1].split(":").map{|n| n.to_i}
          filter_manager.add_location path, lines
        end
        path
      end

      def command
        $0.split(File::SEPARATOR).last
      end

      def value_for(key, default=nil)
        @preferred_options[key] ? @preferred_options[key] : default
      end

      def assert_no_example_groups_defined(config_option)
        if MSpec.world.example_groups.any?
          raise MustBeConfiguredBeforeExampleGroupsError.new(
            "MSpec's #{config_option} configuration option must be configured before " +
            "any example groups are defined, but you have already defined a group."
          )
        end
      end

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
      # def underscore_with_fix_for_non_standard_mspec_naming(string)
      # # activesupport/lib/active_support/inflector/methods.rb, line 48
      # def underscore(camel_cased_word)
      # def file_at(path)

      def order_n_seed_from_seed(value)
        @order, @seed = 'rand', value.to_i
      end

      def order_n_seed_from_order(type)
        order, seed = type.to_s.split(':')
        @order = order
        @seed  = seed = seed.to_i if seed
        @order, @seed = nil, nil if order == 'default'
        return order, seed
      end

  end
end
