require 'spec_helper'

module MSpec
  module Core
    describe Metadata do

      describe "#process" do
        Metadata::RESERVED_KEYS.each do |key|
          it "prohibits :#{key} as a hash key" do
            m = Metadata.new
            expect do
              m.process('group', key => {})
            end.to raise_error(/:#{key} is not allowed/)
          end
        end

        it "uses :caller if passed as part of the user metadata" do
          m = Metadata.new
          m.process('group', :caller => ['example_file:42'])
          m[:example_group][:location].should eq("example_file:42")
        end
      end

      describe "#for_example" do
        let(:metadata)           { Metadata.new.process("group description") }
        let(:mfe)                { metadata.for_example("example description", {:arbitrary => :options}) }
        let(:line_number)        { __LINE__ - 1 }
      
        it "stores the description" do
          mfe[:description].should eq("example description")
        end
      end

    end
  end
end
