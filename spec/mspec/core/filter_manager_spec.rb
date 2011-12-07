require 'spec_helper'

module MSpec::Core
  describe FilterManager do
    def opposite(name)
      name =~ /^in/ ? name.sub(/^(in)/,'ex') : name.sub(/^(ex)/,'in')
    end

    %w[include inclusions exclude exclusions].each_slice(2) do |name, type|
      describe "##{name}" do
        it "merges #{type}" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send name, :foo => :bar
          filter_manager.send name, :baz => :bam
          filter_manager.send(type).should eq(:foo => :bar, :baz => :bam)
        end

        it "overrides previous #{type} with (via merge)" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send name, :foo => 1
          filter_manager.send name, :foo => 2
          filter_manager.send(type).should eq(:foo => 2)
        end

        it "deletes matching opposites" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send name, :foo => 2
          filter_manager.send(type).should eq(:foo => 2)
          filter_manager.send(opposite(type)).should be_empty
        end
      end

      describe "##{name}!" do
        it "replaces existing #{type}" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send name, :foo => 1, :bar => 2
          filter_manager.send "#{name}!", :foo => 3
          filter_manager.send(type).should eq(:foo => 3)
        end

        it "deletes matching opposites" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}!", :foo => 2
          filter_manager.send(type).should eq(:foo => 2)
          filter_manager.send(opposite(type)).should be_empty
        end
      end

      describe "##{name}_with_low_priority" do
        it "ignores new #{type} if same key exists" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send name, :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 2
          filter_manager.send(type).should eq(:foo => 1)
        end

        it "ignores new #{type} if same key exists in opposite" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 1
          filter_manager.send(type).should be_empty
          filter_manager.send(opposite(type)).should eq(:foo => 1)
        end

        it "keeps new #{type} if same key exists in opposite but values are different" do
          filter_manager = FilterManager.new
          filter_manager.exclusions.clear # defaults
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 2
          filter_manager.send(type).should eq(:foo => 2)
          filter_manager.send(opposite(type)).should eq(:foo => 1)
        end
      end
    end

    describe "#prune" do #p till Metadata-filtering
      def example_with(args = {})
        example = double('example')
        example.stub(:any_apply?) { |f| Metadata.new(args).any_apply?(f) }
        example
      end

      xit "includes objects with tags matching inclusions" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      xit "excludes objects with tags matching exclusions" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      xit "prefers exclusion when matches previously set inclusion" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.exclude :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      xit "prefers inclusion when matches previously set exclusion" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.include :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      xit "prefers previously set inclusion when exclusion matches but has lower priority" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.exclude_with_low_priority :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      xit "prefers previously set exclusion when inclusion matches but has lower priority" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.include_with_low_priority :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end
    end

    describe "#inclusions#description" do #p
      pending
    end

    describe "#exclusions#description" do #p
      pending
    end

    it "clears the inclusion filter on include :line_numbers" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :line_numbers => [100]
      filter_manager.inclusions.should eq(:line_numbers => [100])
    end

    it "clears the inclusion filter on include :locations" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :locations => { "path/to/file.rb" => [37] }
      filter_manager.inclusions.should eq(:locations => { "path/to/file.rb" => [37] })
    end

    it "clears the inclusion filter on include :full_description" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :full_description => "this and that"
      filter_manager.inclusions.should eq(:full_description => "this and that")
    end

    [:locations, :line_numbers, :full_description].each do |filter|
      it "does nothing on include if already set standalone filter #{filter}" do
        filter_manager = FilterManager.new
        filter_manager.include filter => "a_value"
        filter_manager.include :foo => :bar
        filter_manager.inclusions.should eq(filter => "a_value")
      end
    end
  end
end
