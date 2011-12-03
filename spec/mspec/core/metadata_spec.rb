require 'spec_helper'

module MSpec::Core
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

    describe "#filter_applies?" do #p
      pending
    end

    describe "#for_example" do
      let(:metadata)           { Metadata.new.process("group description") }
      let(:mfe)                { metadata.for_example("example description", {:arbitrary => :options}) }
      let(:line_number)        { __LINE__ - 1 }

      it "stores the description" do
        mfe[:description].should eq("example description")
      end

      it "stores the full_description (group description + example description)" do
        mfe[:full_description].should eq("group description example description")
      end

      it "creates an empty execution result" do
        mfe[:execution_result].should eq({})
      end

      it "extracts file path from caller" do
        mfe[:file_path].should eq(__FILE__)
      end

      it "extracts line number from caller" do
        mfe[:line_number].should eq(line_number)
      end

      it "extracts location from caller" do
        mfe[:location].should eq("#{__FILE__}:#{line_number}")
      end

      it "uses :caller if passed as an option" do
        example_metadata = metadata.for_example('example description', {:caller => ['example_file:42']})
        example_metadata[:location].should eq("example_file:42")
      end

      it "merges arbitrary options" do
        mfe[:arbitrary].should eq(:options)
      end

      it "points :example_group to the same hash object" do
        a = metadata.for_example("foo", {})[:example_group]
        b = metadata.for_example("bar", {})[:example_group]
        a[:description] = "new description"
        b[:description].should eq("new description")
      end
    end

    [:described_class, :describes].each do |key| #p
      describe key do
        pending
      end
    end

    describe ":description" do
      it "just has the example description" do
        m = Metadata.new
        m.process("group")

        m = m.for_example("example", {})
        m[:description].should eq("example")
      end

      context "with a string" do
        it "provides the submitted description" do
          m = Metadata.new
          m.process("group")

          m[:example_group][:description].should eq("group")
        end
      end

      context "with a non-string" do
        it "provides the submitted description" do
          m = Metadata.new
          m.process(Object)

          m[:example_group][:description].should eq("Object")
        end
      end

      context "with a non-string and a string" do
        it "concats the args" do
          m = Metadata.new
          m.process(Object, 'group')

          m[:example_group][:description].should eq("Object group")
        end
      end

      context "with empty args" do
        it "returns empty string for [:example_group][:description]" do
          m = Metadata.new
          m.process()

          m[:example_group][:description].should eq("")
        end
      end
    end

    describe ":full_description" do #p
      pending
    end

    describe ":file_path" do #p
      pending
    end

    describe ":line_number" do #p
      pending
    end

    describe "child example group" do #p
      pending
    end
  end
end
