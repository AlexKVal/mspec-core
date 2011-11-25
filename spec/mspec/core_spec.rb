require 'spec_helper'

describe MSpec::Core do

  describe "#configuration" do

    it "returns the same object every time" do
      MSpec.configuration.should equal(MSpec.configuration)
    end

  end

  describe "#configure" do

    it "yields the current configuration" do
      MSpec.configure do |config|
        config.should eq(MSpec::configuration)
      end
    end

  end

  describe "#world" do

    it "returns the MSpec::Core::World instance the current run is using" do
      MSpec.world.should be_instance_of(MSpec::Core::World)
    end

  end

end
