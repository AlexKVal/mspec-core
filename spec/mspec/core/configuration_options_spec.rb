require 'spec_helper'
require 'ostruct'

describe MSpec::Core::ConfigurationOptions do
  include ConfigOptionsHelper

  it "warns when HOME env var is not set", :unless => (RUBY_PLATFORM == 'java') do
    begin
      orig_home = ENV.delete("HOME")
      coo = MSpec::Core::ConfigurationOptions.new([])
      coo.should_receive(:warn)
      coo.parse_options
    ensure
      ENV["HOME"] = orig_home
    end
  end

  describe "#configure" do
    it "sends libs before requires" do
      opts = config_options_object(*%w[--require a/path -I a/lib])
      config = double("config").as_null_object
      config.should_receive(:libs=).ordered
      config.should_receive(:requires=).ordered
      opts.configure(config)
    end

    it "sends requires before formatter" do
      opts = config_options_object(*%w[--require a/path -f a/formatter])
      config = double("config").as_null_object
      config.should_receive(:requires=).ordered
      config.should_receive(:add_formatter).ordered
      opts.configure(config)
    end
  end
end
