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

    describe "#filter_applies?" do #p untill World
      it "needs to implement the World first."
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

    describe ":described_class" do
      context "with a String" do
        it "returns nil" do
          m = Metadata.new
          m.process('group')

          m[:example_group][:described_class].should be_nil
        end
      end

      context "with a Symbol" do
        it "returns nil" do
          m = Metadata.new
          m.process(:group)

          m[:example_group][:described_class].should be_nil
        end
      end

      context "with a class" do
        it "returns the class" do
          m = Metadata.new
          m.process(String)

          m[:example_group][:described_class].should be(String)
        end
      end

      context "in a nested group" do
        it "returns the parent group's described class" do
          sm = Metadata.new
          sm.process(String)

          m = Metadata.new(sm)
          m.process(Array)

          m[:example_group][:described_class].should be(String)
        end

        it "returns own described class if parent doesn't have one" do
          sm = Metadata.new
          sm.process("foo")

          m = Metadata.new(sm)
          m.process(Array)

          m[:example_group][:described_class].should be(Array)
        end

        it "can override a parent group's described class" do
          parent = Metadata.new
          parent.process(String)

          child = Metadata.new(parent)
          child.process(Fixnum)
          child[:example_group][:described_class] = Hash

          grandchild = Metadata.new(child)
          grandchild.process(Array)

          grandchild[:example_group][:described_class].should be(Hash)
          child[:example_group][:described_class].should be(Hash)
          parent[:example_group][:described_class].should be(String)
        end
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

    describe ":full_description" do
      it "concats example group name and description" do
        group_metadata = Metadata.new
        group_metadata.process('group')

        example_metadata = group_metadata.for_example("example", {})
        example_metadata[:full_description].should eq("group example")
      end

      it "concats nested example group descriptions" do
        parent = Metadata.new
        parent.process('parent')

        child = Metadata.new(parent)
        child.process('child')

        child[:example_group][:full_description].should eq("parent child")
        child.for_example('example', {})[:full_description].should eq("parent child example")
      end

      it "concats nested example group descriptions three deep" do
        grandparent = Metadata.new
        grandparent.process('grandparent')

        parent = Metadata.new(grandparent)
        parent.process('parent')

        child = Metadata.new(parent)
        child.process('child')

        grandparent[:example_group][:full_description].should eq("grandparent")
        parent[:example_group][:full_description].should eq("grandparent parent")
        child[:example_group][:full_description].should eq("grandparent parent child")
        child.for_example('example', {})[:full_description].should eq("grandparent parent child example")
      end

      %w[# . ::].each do |char|
        context "with a 2nd arg starting with #{char}" do
          it "removes the space" do
            m = Metadata.new
            m.process(Array, "#{char}method")
            m[:example_group][:full_description].should eq("Array#{char}method")
          end
        end
      end

      %w[# . ::].each do |char|
        context "with a nested description starting with #{char}" do
          it "removes the space" do
            parent = Metadata.new
            parent.process("Object")
            child = Metadata.new(parent)
            child.process("#{char}method")
            child[:example_group][:full_description].should eq("Object#{char}method")
          end
        end
      end
    end

    describe ":file_path" do
      it "finds the first non-rspec lib file in the caller array" do
        m = Metadata.new
        m.process(:caller => [
                    "./lib/rspec/core/foo.rb",
                    "#{__FILE__}:#{__LINE__}"
        ])
        m[:example_group][:file_path].should eq(__FILE__)
      end
    end

    describe ":line_number" do
      it "finds the line number with the first non-rspec lib file in the backtrace" do
        m = Metadata.new
        m.process({})
        m[:example_group][:line_number].should eq(__LINE__ - 1)
      end

      it "finds the line number with the first spec file with drive letter" do
        m = Metadata.new
        m.process(:caller => [ "C:/path/to/file_spec.rb:#{__LINE__}" ])
        m[:example_group][:line_number].should eq(__LINE__ - 1)
      end

      it "uses the number after the first : for ruby 1.9" do
        m = Metadata.new
        m.process(:caller => [ "#{__FILE__}:#{__LINE__}:999" ])
        m[:example_group][:line_number].should eq(__LINE__ - 1)
      end
    end

    describe "child example group" do
      it "nests the parent's example group metadata" do
        parent = Metadata.new
        parent.process(Object, 'parent')

        child = Metadata.new(parent)
        child.process()

        child[:example_group][:example_group].should eq(parent[:example_group])
      end
    end
  end
end
