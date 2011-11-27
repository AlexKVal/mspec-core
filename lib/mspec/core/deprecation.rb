# this file has been copied from RSpec project
# because it has no dedicated spec file
module MSpec
  class << self
    # @api private
    #
    # Used internally to print deprecation warnings
    def deprecate(method, alternate_method=nil, version=nil)
      version_string = version ? "mspec-#{version}" : "a future version of MSpec"

      message = <<-NOTICE

      *****************************************************************
      DEPRECATION WARNING: you are using deprecated behaviour that will
      be removed from #{version_string}.

      #{caller(0)[2]}

      * #{method} is deprecated.
      NOTICE
      if alternate_method
        message << <<-ADDITIONAL
        * please use #{alternate_method} instead.
        ADDITIONAL
      end

      message << "*****************************************************************"
      warn_deprecation(message)
    end

    # @api private
    #
    # Used internally to print deprecation warnings
    def warn_deprecation(message)
      send :warn, message
    end
  end

  # @private
  # class HashWithDeprecationNotice < Hash
  # 
  #   def initialize(method, alternate_method=nil)
  #     @method, @alternate_method = method, alternate_method
  #   end
  # 
  #   def []=(k,v)
  #     MSpec.deprecate(@method, @alternate_method)
  #     super(k,v)
  #   end
  # 
  # end

end
