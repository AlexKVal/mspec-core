require 'rubygems'

begin
  require 'spork'
rescue LoadError
  module Spork
    def self.prefork
      yield
    end

    def self.each_run
      yield
    end
  end
end

Spork.prefork do
  require 'rspec/autorun'

  Dir['./spec/support/**/*.rb'].map {|f| require f}

  def in_editor?
    ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
  end

  RSpec.configure do |c|
    # structural
    c.alias_it_should_behave_like_to 'it_has_behavior'

    # runtime options
    c.treat_symbols_as_metadata_keys_with_true_values = true
    c.color = !in_editor?
  end
end

Spork.each_run do
end
