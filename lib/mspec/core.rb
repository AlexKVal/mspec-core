def require_mspec(path)
  require "mspec/#{path}"
end

require_mspec 'core/filter_manager'
require_mspec 'core/deprecation'

require_mspec 'core/world'
require_mspec 'core/configuration'
require_mspec 'core/option_parser'
require_mspec 'core/configuration_options'
require_mspec 'core/example_group'
require_mspec 'core/version'

module MSpec
  def self.configuration
    @configuration ||= MSpec::Core::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

  def self.world
    @world ||= MSpec::Core::World.new
  end

  module Core
  end
end
