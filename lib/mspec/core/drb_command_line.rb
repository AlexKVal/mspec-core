module MSpec
  module Core
    class DRbCommandLine
      def initialize(options)
        @options = options
      end

      def run(err, out)
        raise DRb::DRbConnError if @options.drb_argv.empty?
      end
    end
  end
end
