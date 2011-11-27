module MSpec
  module Core
    class ConfigurationOptions
      attr_reader :options

      def initialize(args)
        @args = args
      end

      def parse_options
        warn if ENV["HOME"].nil?
      end

      def configure(config)
        config.libs = nil
        config.requires = nil
        config.add_formatter
      end

      def warn

      end
    end
  end
end
