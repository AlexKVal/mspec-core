module MSpec
  module Core
    class DRbCommandLine
      def initialize(options)
        @options = options
      end

      def run(err, out)
        # raise DRb::DRbConnError if @options.drb_argv.empty?
      end

      def drb_port
        @options.options[:drb_port] || ENV['MSPEC_DRB'] || 8989
      end
    end
  end
end
