def require_mspec(path)
  require "mspec/#{path}"
end

require_mspec 'core/world'
require_mspec 'core/configuration'

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