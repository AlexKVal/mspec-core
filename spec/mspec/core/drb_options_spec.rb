require "spec_helper"

describe MSpec::Core::DrbOptions do
  include ConfigOptionsHelper

  describe "#drb_argv" do
    it "preserves extra arguments" do
      File.stub(:exist?) { false }
      config_options_object(*%w[ a --drb b --color c ]).drb_argv.should =~ %w[ --color a b c ]
    end

    it "includes --fail-fast" do
      config_options_object(*%w[--fail-fast]).drb_argv.should include("--fail-fast")
    end

    it "includes --options" do
      config_options_object(*%w[--options custom.opts]).drb_argv.should include("--options", "custom.opts")
    end

    it "includes --order" do
      config_options_object(*%w[--order random]).drb_argv.should include('--order', 'random')
    end

    context "with --example" do
      it "includes --example" do
        config_options_object(*%w[--example foo]).drb_argv.should include("--example", "foo")
      end

      it "unescapes characters which were escaped upon storing --example originally" do
        config_options_object("--example", "foo\\ bar").drb_argv.should include("--example", "foo bar")
      end
    end
  end
end
