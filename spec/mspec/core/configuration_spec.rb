require 'spec_helper'
require 'tmpdir'

# so the stdlib module is available...
#module Test; module Unit; module Assertions; end; end; end

module MSpec::Core

  describe Configuration do

    let(:config) { Configuration.new }

    describe "#load_spec_files" do

      it "loads files using load" do
        config.files_to_run = ["foo.bar", "blah_spec.rb"]
        config.should_receive(:load).twice
        config.load_spec_files
      end

      context "with rspec-1 loaded" do
        before do
          Object.const_set(:Spec, Module.new)
          ::Spec::const_set(:VERSION, Module.new)
          ::Spec::VERSION::const_set(:MAJOR, 1)
        end
        after  { Object.__send__(:remove_const, :Spec) }
        it "raises with a helpful message" do
          expect {
            config.load_spec_files
          }.to raise_error(/rspec-1 has been loaded/)
        end
      end
    end

    describe "#treat_symbols_as_metadata_keys_with_true_values?" do
      xit 'defaults to false' do
        config.treat_symbols_as_metadata_keys_with_true_values?.should be_false
      end

      xit 'can be set to true' do
        config.treat_symbols_as_metadata_keys_with_true_values = true
        config.treat_symbols_as_metadata_keys_with_true_values?.should be_true
      end
    end

    describe "#mock_framework" do
      xit "defaults to :mspec" do
        config.should_receive(:require).with('mspec/core/mocking/with_mspec')
        config.mock_framework
      end
    end

    describe "#mock_framework="do
      xit "delegates to mock_with" do
        config.should_receive(:mock_with).with(:mspec)
        config.mock_framework = :mspec
      end
    end

    describe "#mock_with" do
      [:mspec, :mocha, :rr, :flexmock].each do |framework|
        context "with #{framework}" do
          xit "requires the adapter for #{framework.inspect}" do
            config.should_receive(:require).with("mspec/core/mocking/with_#{framework}")
            config.mock_with framework
          end
        end
      end

      context "with a module" do
        xit "sets the mock_framework_adapter to that module" do
          config.stub(:require)
          mod = Module.new
          config.mock_with mod
          config.mock_framework.should eq(mod)
        end
      end

      xit "uses the null adapter when set to any unknown key" do
        config.should_receive(:require).with('mspec/core/mocking/with_absolutely_nothing')
        config.mock_with :crazy_new_mocking_framework_ive_not_yet_heard_of
      end

      context 'when there are already some example groups defined' do
        pending
        before(:each) { config.stub(:require) }

        xit 'raises an error since this setting must be applied before any groups are defined' do
          MSpec.world.stub(:example_groups).and_return([double.as_null_object])
          expect {
            config.mock_with :mocha
          }.to raise_error(/must be configured before any example groups are defined/)
        end

        xit 'does not raise an error if the default `mock_with :rspec` is re-configured' do
          config.mock_framework # called by MSpec when configuring the first example group
          MSpec.world.stub(:example_groups).and_return([double.as_null_object])
          config.mock_with :mspec
        end

        xit 'does not raise an error if re-setting the same config' do
          groups = []
          MSpec.world.stub(:example_groups => groups)
          config.mock_with :mocha
          groups << double.as_null_object
          config.mock_with :mocha
        end
      end
    end
  end
end
