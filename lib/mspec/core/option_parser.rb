#http://www.ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
require 'optparse'

module MSpec::Core
  class Parser
    def parse!(args)
      opts = OptionParser.new unless args.empty?
    end
  end
end
