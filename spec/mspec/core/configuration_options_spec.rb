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

    it "sends default_path before files_or_directories_to_run" do
      opts = config_options_object(*%w[--default_path my_specs])
      config = double("config").as_null_object
      config.should_receive(:force).with(:default_path => 'my_specs').ordered
      config.should_receive(:files_or_directories_to_run=).ordered
      opts.configure(config)
    end

    it "sends pattern before files_or_directories_to_run" do
      opts = config_options_object(*%w[--pattern **/*.spec])
      config = double("config").as_null_object
      config.should_receive(:force).with(:pattern => '**/*.spec').ordered
      config.should_receive(:files_or_directories_to_run=).ordered
      opts.configure(config)
    end

    it "merges the :exclusion_filter option with the default exclusion_filter" do
      opts = config_options_object(*%w[--tag ~slow])
      config = MSpec::Core::Configuration.new
      opts.configure(config)
      config.exclusion_filter.should have_key(:slow)
    end

    it "forces color_enabled" do
      opts = config_options_object('--color')
      config = double("config").as_null_object
      config.should_receive(:force).with(:color => true)
      opts.configure(config)
    end

    [
      ["--failure-exit-code", "3", :failure_exit_code, 3],
      ["--pattern", "foo/bar", :pattern, "foo/bar"],
      ["--failure-exit-code", "37", :failure_exit_code, 37],
      ["--default_path", "behavior", :default_path, "behavior"],
      ["--drb", nil, :drb, true],
      ["--order", "rand", :order, "rand"],
      ["--seed", "37", :order, "rand:37"],
      ["--drb-port", "37", :drb_port, 37],
      ["--backtrace", nil, :full_backtrace, true], # method full_backtrace=
      #       ["--profile", nil, :profile_examples, true],
      #       ["--tty", nil, :tty, true]
    ].each do |cli_option, cli_value, config_key, config_value|
      it "forces #{config_key}" do
        opts = config_options_object(*[cli_option, cli_value].compact)
        config = MSpec::Core::Configuration.new
        config.should_receive(:force) do |pair|
          pair.keys.first.should eq(config_key)
          pair.values.first.should eq(config_value)
        end
        opts.configure(config)
      end
    end

    it "sets debug directly" do
      opts = config_options_object("--debug")
      config = double("config").as_null_object
      config.should_receive(:debug=).with(true)
      opts.configure(config)
    end
  end

  describe "-c, --color and --colour" do
    it "sets :color => true" do
      %w(-c --color --colour).each do |arg|
        parse_options(arg)[:color].should be_true
      end
    end
  end

  describe "--no-color" do
    it "sets :color => false" do
      parse_options('--no-color')[:color].should be_false
    end

    it "overrides previous :color => true" do
      parse_options('--color', '--no-color')[:color].should be_false
    end

    it "gets overriden by a subsequent :color => true" do
      parse_options('--no-color', '--color')[:color].should be_true
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

  describe "--profile, -p" do
    it "sets :profile_examples => true" do
      %w(--profile -p).each { |arg| parse_options(arg)[:profile_examples].should be_true }
    end
  end

  describe '--line_number, -l' do
    it "sets :line_number" do
      %w(--line_number -l).each do |arg|
        parse_options(arg, '3')[:line_numbers].should == ['3']
      end
    end

    it "can be specified multiple times" do
      %w(--line_number -l).each do |arg|
        parse_options(arg, '3', arg, '6')[:line_numbers].should == ['3', '6']
      end
    end
  end

  describe "--example" do
    it "sets :full_description" do
      parse_options('--example','foo').should include(:full_description => /foo/)
      parse_options('-e','bar').should include(:full_description => /bar/)
    end
  end

  describe "--backtrace, -b" do
    it "sets :full_backtrace => true" do
      %w(--backtrace -b).each do |arg|
        parse_options(arg)[:full_backtrace].should be_true
      end
    end
  end

  describe "--debug, -d" do
    it "sets :debug => true" do
      %w(--debug -d).each { |arg| parse_options("-d")[:debug].should be_true }
    end
  end

  describe "--fail-fast" do
    it "defaults to false" do
      parse_options[:fail_fast].should be_false
    end

    it "sets fail_fast on config" do
      parse_options("--fail-fast")[:fail_fast].should be_true
    end
  end

  describe "--failure-exit-code" do
    it "sets :failure_exit_code" do
      (0..2).each do |code|
        parse_options('--failure-exit-code', code.to_s)[:failure_exit_code].should == code
      end
    end

    it "overrides previous :failure_exit_code" do
      parse_options('--failure-exit-code', '2', '--failure-exit-code', '3')[:failure_exit_code].should == 3
    end
  end

  describe "--options -O" do
    it "sets :custom_options_file" do
      %w(--options -O).each do |arg|
        parse_options(arg, 'my.opts')[:custom_options_file].should == 'my.opts'
      end
    end
  end

  describe "files_or_directories_to_run" do
    it "parses files from '-c file.rb dir/file.rb'" do
      parse_options("-c", "file.rb", "dir/file.rb")
        .should include(:files_or_directories_to_run => ["file.rb", "dir/file.rb"])
    end

    it "parses dir from 'dir'" do
      parse_options("dir").should include(:files_or_directories_to_run => ["dir"])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      parse_options("dir", "spec/file1_spec.rb", "spec/file2_spec.rb")
        .should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])
    end

    it "provides no files or directories if spec directory does not exist" do
      File.stub(:directory?).with("spec").and_return true
      parse_options()[:files_or_directories_to_run].should be_empty
    end
  end
end
