require 'spec_helper'

module MSpec::Core
  describe FilterManager do
    %w[inclusions include exclusions exclude].each_slice(2) do |type, name|
      it "merges #{type}" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => :bar
        filter_manager.send name, :baz => :bam
        filter_manager.send(type).should eq(:foo => :bar, :baz => :bam)
      end

      it "overrides previous #{type} (via merge)" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => 1
        filter_manager.send name, :foo => 2
        filter_manager.send(type).should eq(:foo => 2)
      end

      it "ignores new #{type} if same key exists and priority is low" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => 1
        filter_manager.send name, :low_priority, :foo => 2
        filter_manager.send(type).should eq(:foo => 1)
      end
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
  end
end
