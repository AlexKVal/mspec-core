module MSpec
  module Core
    class DRbCommandLine
      def initialize(options)
        @options = options
      end

      def run(err, out)
        raise DRb::DRbConnError if @options.drb_argv.empty?
      end

      def drb_port
        return 8989 if ENV['MSPEC_DRB'].nil? && @options.options[:drb_port].nil?
      end
    end
  end
end
