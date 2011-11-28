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

  describe "-I" do
    example "adds to :libs" do
      parse_options('-I', 'a_dir').should include(:libs => ['a_dir'])
    end
    example "can be used more than once" do
      parse_options('-I', 'dir_1', '-I', 'dir_2').should include(:libs => ['dir_1','dir_2'])
    end
  end

  describe '--require' do
    example "requires files" do
      parse_options('--require', 'a/path').should include(:requires => ['a/path'])
    end
    example "can be used more than once" do
      parse_options('--require', 'path/1', '--require', 'path/2').should include(:requires => ['path/1','path/2'])
    end
  end

  describe "--format, -f" do
    it "sets :formatter" do
      [['--format', 'd'], ['-f', 'd'], '-fd'].each do |args|
        parse_options(*args).should include(:formatters => [['d']])
      end
    end

    example "can accept a class name" do
      parse_options('-fSome::Formatter::Class').should include(:formatters => [['Some::Formatter::Class']])
    end
  end
end
