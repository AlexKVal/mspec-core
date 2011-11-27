#http://www.ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
require 'optparse'

module MSpec::Core
  class Parser
    def self.parse!(args)
      new.parse!(args)
    end

    def parse!(args)
      return {} if args.empty?
      if args.include?("--formatter")
        MSpec.deprecate("the --formatter option", "-f or --format")
        args[args.index("--formatter")] = "--format"
      end
      options = {}
      parser(options).parse!(args)
      options
    end

    def parser(options)
      OptionParser.new do |parser|
        parser.banner = "Usage: mspec [options] [files or directories]\n\n"

        parser.on('-I PATH', 'specify PATH to add to $LOAD_PATH (may be used more than once)') do |dir|
          options[:libs] ||= []
          options[:libs] << dir
        end

        # parser.on('-r', '--require PATH', 'Require a file') do |path|

        # parser.on('-O', '--options PATH', 'Specify the path to a custom options file') do |path|

         parser.on('--order TYPE', 'Run examples by the specified order type',
                   '  [rand] randomized',
                   '  [random] alias for rand',
                   '  [random:SEED] e.g. --order random:123'
                   ) do |o|
          options[:order] = o
        end

        parser.on('--seed SEED', "Equivalent of --order rand:SEED") do |seed|
          options[:order] = "rand:#{seed}"
        end

        # parser.on('-d', '--debugger', 'Enable debugging') do |o|
        # parser.on('--fail-fast', 'Abort the run on first failure') do |o|
        # parser.on('--failure-exit-code CODE', 'Override the exit code used when there are failing specs') do |o|
        # parser.on('-X', '--[no-]drb', 'Run examples via DRb') do |o|
        # parser.on('--drb-port PORT', 'Port to connect to on the DRb server') do |o|
        # parser.on("--tty", "Used internally by rspec when sending commands to other processes") do |o|
        # parser.on('--init', 'Initialize your project with RSpec.') do |cmd|
        # parser.on('--configure', 'Deprecated. Use --init instead.') do |cmd|
        #
        parser.separator("\n  **** Output formatting ****\n\n")

        parser.on("-f", "--format FORMATTER", "Choose a formatter",
                  '  [p]rogress (default - dots)',
                  '  [d]ocumentation (group and example names)',
                  '  [h]tml',
                  '  [t]extmate',
                  '  custom formatter class name'
        ) do |o|
          options[:formatters] ||= []
          options[:formatters] << [o]
        end

        parser.on("-o", "--out FILE",
                  'Write output to a file instead of STDOUT. This option applies',
                  'to the previously specified --format, or the default format if',
                  'no format is specified.'
        ) do |o|
          options[:formatters] ||= [["progress"]]
          options[:formatters].last << o
        end

        # parser.on('-b', '--backtrace', 'Enable full backtrace') do |o|
        # parser.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
        # parser.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|

        parser.separator <<-FILTERING

  **** Filtering and tags ****

    In addition to the following options for selecting specific files, groups,
    or examples, you can select a single example by appending the line number to
    the filename:

      mspec path/to/a_spec.rb:37

FILTERING

        parser.on('-P', '--pattern PATTERN', 'Load files matching pattern (default: "spec/**/*_spec.rb")') do |o|
          options[:pattern] = o
        end

        parser.on('-e', '--example STRING', "Run examples whose full nested names include STRING") do |o|
          options[:full_description] = Regexp.new(Regexp.escape(o))
        end

        # parser.on('-l', '--line_number LINE', 'Specify line number of an example or group (may be specified multiple times)') do |o|

        parser.on('-t', '--tag TAG[:VALUE]',
                  'Run examples with the specified tag, or exclude',
                  'examples by adding ~ before the tag (e.g. ~slow)',
                  '(TAG is always converted to a symbol)'
        ) do |tag|
          filter_type = tag =~ /^~/ ? :exclusion_filter : :inclusion_filter
          
          name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
          value = value.nil? ? true : eval(value)
          
          options[filter_type] ||= {}
          options[filter_type][name.to_sym] = value
        end

        # parser.on('--default_path PATH', 'Set the default path where RSpec looks for examples.',
                                          #'Can be a path to a file or a directory') do |path|

        parser.separator("\n  **** Utility ****\n\n")

        parser.on('-v', '--version', 'Show version') do
          puts MSpec::Core::Version::STRING
          exit
        end

        parser.on_tail('-h', '--help', "You're looking at it.") do
          puts parser
          exit
        end
      end
    end
  end
end
