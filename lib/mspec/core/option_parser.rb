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
        
        #
        ##
        #
        
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
