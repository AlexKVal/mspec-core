require 'spec_helper'
require 'tmpdir'

# emulate that the stdlib module is available...
module Test; module Unit; module Assertions; end; end; end

module MSpec
  # emulate that the mock and matchers modules is available
  module Matchers; end
  module Core
    module MockFrameworkAdapter; def self.framework_name; :mspec end; end

    describe Configuration do #p

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
        it 'defaults to false' do
          config.treat_symbols_as_metadata_keys_with_true_values?.should be_false
        end

        it 'can be set to true' do
          config.treat_symbols_as_metadata_keys_with_true_values = true
          config.treat_symbols_as_metadata_keys_with_true_values?.should be_true
        end
      end

      describe "#mock_framework" do
        it "defaults to :mspec" do
          config.should_receive(:require).with('mspec/core/mocking/with_mspec')
          config.mock_framework
        end
      end

      describe "#mock_framework="do
        it "delegates to mock_with" do
          config.should_receive(:mock_with).with(:mspec)
          config.mock_framework = :mspec
        end
      end

      describe "#mock_with" do
        [:mspec, :mocha, :rr, :flexmock].each do |framework|
          context "with #{framework}" do
            it "requires the adapter for #{framework.inspect}" do
              config.should_receive(:require).with("mspec/core/mocking/with_#{framework}")
              config.mock_with framework
            end
          end
        end

        context "with a module" do
          it "sets the mock_framework_adapter to that module" do
            config.stub(:require)
            mod = Module.new
            config.mock_with mod
            config.mock_framework.should eq(mod)
          end
        end

        it "uses the null adapter when set to any unknown key" do
          config.should_receive(:require).with('mspec/core/mocking/with_absolutely_nothing')
          config.mock_with :crazy_new_mocking_framework_ive_not_yet_heard_of
        end

        context 'when there are already some example groups defined' do
          before(:each) { config.stub(:require) }

          it 'raises an error since this setting must be applied before any groups are defined' do
            MSpec.world.stub(:example_groups).and_return([double.as_null_object])
            expect {
              config.mock_with :mocha
            }.to raise_error(/must be configured before any example groups are defined/)
          end

          it 'does not raise an error if the default `mock_with :mspec` is re-configured' do
            config.mock_framework # called by MSpec when configuring the first example group
            MSpec.world.stub(:example_groups).and_return([double.as_null_object])
            config.mock_with :mspec
          end

          it 'does not raise an error if re-setting the same config' do
            groups = []
            MSpec.world.stub(:example_groups => groups)
            config.mock_with :mocha
            groups << double.as_null_object
            config.mock_with :mocha
          end
        end
      end

      describe "#expectation_framework" do
        it "defaults to :mspec" do
          config.should_receive(:require).with('mspec/expectations')
          config.expectation_frameworks
        end
      end

      describe "#expectation_framework=" do
        it "delegates to expect_with=" do
          config.should_receive(:expect_with).with(:mspec)
          config.expectation_framework = :mspec
        end
      end

      describe "#expect_with" do
        before(:each) do
          # we need to prevent stdlib from being required because it defines a
          # `pass` method that conflicts with our `pass` matcher.
          config.stub(:require)
        end

        [
          [:mspec,  'mspec/expectations'],
          [:stdlib, 'test/unit/assertions']
        ].each do |framework, required_file|
          context "with #{framework}" do
            it "requires #{required_file}" do
              config.should_receive(:require).with(required_file)
              config.expect_with framework
            end
          end
        end

        it "raises ArgumentError if framework is not supported" do
          expect do
            config.expect_with :not_supported
          end.to raise_error(ArgumentError)
        end

        context 'when there are already some example groups defined' do
          it 'raises an error since this setting must be applied before any groups are defined' do
            MSpec.world.stub(:example_groups).and_return([double.as_null_object])
            expect {
              config.expect_with :mspec
            }.to raise_error(/must be configured before any example groups are defined/)
          end

          it 'does not raise an error if the default `expect_with :mspec` is re-configured' do
            config.expectation_frameworks # called by MSpec when configuring the first example group
            MSpec.world.stub(:example_groups).and_return([double.as_null_object])
            config.expect_with :mspec
          end

          it 'does not raise an error if re-setting the same config' do
            groups = []
            MSpec.world.stub(:example_groups => groups)
            config.expect_with :stdlib
            groups << double.as_null_object
            config.expect_with :stdlib
          end
        end
      end

      describe "#expecting_with_mspec?" do
        before(:each) do
          # prevent minitest assertions from being required and included,
          # as that causes problems in some of our specs.
          config.stub(:require)
        end

        it "returns false by default" do
          config.should_not be_expecting_with_mspec
        end

        it "returns true when `expect_with :mspec` has been configured" do
          config.expect_with :mspec
          config.should be_expecting_with_mspec
        end

        it "returns true when `expect_with :mspec, :stdlib` has been configured" do
          config.expect_with :mspec, :stdlib
          config.should be_expecting_with_mspec
        end

        it "returns true when `expect_with :stdlib, :mspec` has been configured" do
          config.expect_with :stdlib, :mspec
          config.should be_expecting_with_mspec
        end

        it "returns false when `expect_with :stdlib` has been configured" do
          config.expect_with :stdlib
          config.should_not be_expecting_with_mspec
        end
      end

      describe "#files_to_run" do #p
        it "loads files not following pattern if named explicitly" do
          config.files_or_directories_to_run = "spec/mspec/core/resources/a_bar.rb"
          config.files_to_run.should       eq(["spec/mspec/core/resources/a_bar.rb"])
        end

        it "prevents repitition of dir when start of the pattern" do
          config.pattern = "spec/**/a_spec.rb"
          config.files_or_directories_to_run = "spec"
          config.files_to_run.should eq(["spec/mspec/core/resources/a_spec.rb"])
        end

        it "does not prevent repitition of dir when later of the pattern" do
          config.pattern = "mspec/**/a_spec.rb"
          config.files_or_directories_to_run = "spec"
          config.files_to_run.should eq(["spec/mspec/core/resources/a_spec.rb"])
        end

        context "with <path>:<line_number>" do #p
          xit "overrides inclusion filters set on config" do
            config.filter_run_including :foo => :bar
            config.files_or_directories_to_run = "path/to/file.rb:37"
            config.inclusion_filter.size.should eq(1)
            config.inclusion_filter[:locations].keys.first.should match(/path\/to\/file\.rb$/)
            config.inclusion_filter[:locations].values.first.should eq([37])
          end

          xit "overrides inclusion filters set before config" do
            config.force(:inclusion_filter => {:foo => :bar})
            config.files_or_directories_to_run = "path/to/file.rb:37"
            config.inclusion_filter.size.should eq(1)
            config.inclusion_filter[:locations].keys.first.should match(/path\/to\/file\.rb$/)
            config.inclusion_filter[:locations].values.first.should eq([37])
          end

          xit "clears exclusion filters set on config" do
            config.exclusion_filter = { :foo => :bar }
            config.files_or_directories_to_run = "path/to/file.rb:37"
            config.exclusion_filter.should be_empty,
              "expected exclusion filter to be empty:\n#{config.exclusion_filter}"
          end

          xit "clears exclusion filters set before config" do
            config.force(:exclusion_filter => { :foo => :bar })
            config.files_or_directories_to_run = "path/to/file.rb:37"
            config.exclusion_filter.should be_empty,
              "expected exclusion filter to be empty:\n#{config.exclusion_filter}"
          end
        end

        context "with default pattern" do
          xit "loads files named _spec.rb" do
            config.files_or_directories_to_run = "spec/rspec/core/resources"
            config.files_to_run.should eq([      "spec/rspec/core/resources/a_spec.rb"])
          end

          xit "loads files in Windows" do
            file = "C:\\path\\to\\project\\spec\\sub\\foo_spec.rb"
            config.files_or_directories_to_run = file
            config.files_to_run.should eq([file])
          end
        end

        context "with default default_path" do
          xit "loads files in the default path when run by rspec" do
            config.stub(:command) { 'rspec' }
            config.files_or_directories_to_run = []
            config.files_to_run.should_not be_empty
          end

          xit "does not load files in the default path when run by ruby" do
            config.stub(:command) { 'ruby' }
            config.files_or_directories_to_run = []
            config.files_to_run.should be_empty
          end
        end
      end



    end
  end
end
