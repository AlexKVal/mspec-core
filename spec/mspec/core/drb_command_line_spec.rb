require "spec_helper"

describe "::DRbCommandLine", :type => :drb, :unless => RUBY_PLATFORM == 'java' do
  let(:config) { MSpec::Core::Configuration.new }
  let(:out)    { StringIO.new }
  let(:err)    { StringIO.new }

  include_context "spec files"

  def command_line(args)
    MSpec::Core::DRbCommandLine.new(config_options(args))
  end

  def config_options(argv=[])
    options = MSpec::Core::ConfigurationOptions.new(argv)
    options.parse_options
    options
  end

  def run_with(args)
    command_line(args).run(err, out)
  end
end