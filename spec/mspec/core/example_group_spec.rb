require 'spec_helper'

module MSpec::Core

  describe ExampleGroup do #p till Configure
    # it_behaves_like "metadata hash builder" do
    #   def metadata_hash(*args)
    #     group = ExampleGroup.describe('example description', *args)
    #     group.metadata
    #   end
    # end

    context 'when treat_symbols_as_metadata_keys_with_true_values is set to false' do
      pending
      before(:each) do
        MSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = false }
      end

      xit 'processes string args as part of the description' do
        group = ExampleGroup.describe("some", "separate", "strings")
        group.description.should eq("some separate strings")
      end

      xit 'processes symbol args as part of the description' do
        Kernel.stub(:warn) # to silence Symbols as args warning
        group = ExampleGroup.describe(:some, :separate, :symbols)
        group.description.should eq("some separate symbols")
      end
    end

    context 'when MSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to true' do
      pending
      let(:group) { ExampleGroup.describe(:symbol) }

      before(:each) do
        MSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = true }
      end

      xit 'does not treat the first argument as a metadata key even if it is a symbol' do
        group.metadata.should_not include(:symbol)
      end

      xit 'treats the first argument as part of the description when it is a symbol' do
        group.description.should eq("symbol")
      end
    end

  end
end
