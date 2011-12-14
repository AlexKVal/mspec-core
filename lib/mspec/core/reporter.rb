module MSpec::Core
  class Reporter
    def initialize(*formatters)
      @formatters = formatters
      @example_count = @failure_count = @pending_count = 0
      @duration = @start = nil
    end
  end
end
