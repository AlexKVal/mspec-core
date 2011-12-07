require 'spec_helper'

module MSpec::Core

  describe World do #p till ExampleGroup
    let(:configuration) { Configuration.new }
    let(:world) { World.new(configuration) }

    describe "#example_groups" do
      xit "contains all registered example groups" do
        group = ExampleGroup.describe("group")
        world.register(group)
        world.example_groups.should include(group)
      end
    end

  end
end
