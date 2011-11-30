require "spec_helper"

describe MSpec::Core::DrbOptions do
  include ConfigOptionsHelper

  describe "#drb_argv" do
    it "preserves extra arguments" do
      File.stub(:exist?) { false }
      config_options_object(*%w[ a --drb b --color c ]).drb_argv.should =~ %w[ --color a b c ]
    end

    %w(--color --fail-fast --profile --backtrace --tty).each do |option|
      it "includes #{option}" do
        config_options_object("#{option}").drb_argv.should include("#{option}")
      end
    end

    it "includes --failure-exit-code" do
      config_options_object(*%w[--failure-exit-code 2]).drb_argv.should include("--failure-exit-code", "2")
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

    context "with formatters" do
      it "includes the formatters" do
        config_options_object(*%w[--format d]).drb_argv.should include("--format", "d")
      end

      it "leaves formatters intact" do
        coo = config_options_object("--format", "d")
        coo.drb_argv
        coo.options[:formatters].should include(["d"])
      end

      it "leaves output intact" do
        coo = config_options_object("--format", "p", "--out", "foo.txt", "--format", "d")
        coo.drb_argv
        coo.options[:formatters].should include(["p","foo.txt"],["d"])
      end
    end

    context "with --out" do
      it "combines with formatters" do
        coo = config_options_object("--format", "h", "--out", "report.html")
        coo.drb_argv.should include("--format", "h", "--out", "report.html")
      end
    end

    context "with tags" do
      it "includes the inclusion tags" do
        pending "untill filter_manager"
        coo = config_options_object("--tag", "wip")
        coo.drb_argv.should eq(["--tag", "wip"])
      end
    end
  end
end
