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

  context "without server running" do
    it "raises an error" do
      expect { run_with [] }.should raise_error(DRb::DRbConnError)
    end
  end

  describe "--drb-port" do
    def with_MSPEC_DRB_set_to(val)
      original = ENV['MSPEC_DRB']
      ENV['MSPEC_DRB'] = val
      begin
        yield
      ensure
        ENV['MSPEC_DRB'] = original
      end
    end

    context "without MSPEC_DRB environment variable set" do
      it "defaults to 8989" do
        with_MSPEC_DRB_set_to(nil) do
          command_line([]).drb_port.should eq(8989)
        end
      end

      it "sets the DRb port from command line options" do
        with_MSPEC_DRB_set_to(nil) do
          command_line(["--drb-port", "1234"]).drb_port.should eq(1234)
          command_line(["--drb-port", "5678"]).drb_port.should eq(5678)
        end
      end
    end

    context "with MSPEC_DRB environment variable set" do
      context "without config variable in config options set" do
        it "uses MSPEC_DRB value" do
          with_MSPEC_DRB_set_to('9000') do
            command_line([]).drb_port.should eq("9000")
          end
        end
      end

      context "and config variable set" do
        it "uses configured value" do
          with_MSPEC_DRB_set_to('9000') do
            command_line(%w[--drb-port 5678]).drb_port.should eq(5678)
          end
        end
      end
    end
  end
end