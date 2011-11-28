module MSpec::Core
  class ConfigurationOptions
    attr_reader :options

    def initialize(args)
      @args = args
    end

    def parse_options
      warn if ENV["HOME"].nil?

      @options ||= Parser.parse!(@args)
    end

    def configure(config)
      order(options.keys, :libs, :requires).each do |key|
        config.send("#{key}=", options[key])
      end
      config.add_formatter
    end

    private
      def order(keys, *ordered)
        ordered.reverse.each do |key|
          keys.unshift(key) if keys.delete(key)
        end
        keys
      end

  end
end
