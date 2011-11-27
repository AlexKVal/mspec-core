require "spec_helper"

module RSpec::Core
  describe OptionParser do
    let(:output_file){ mock File }

    before do
      MSpec.stub(:deprecate)
      File.stub(:open).with("foo.txt",'w') { (output_file) }
    end


  end
end
