#require 'mspec/mocks'

module MSpec
  module Core
    module MockFrameworkAdapter
      
      def self.framework_name; :rr end

      def setup_mocks_for_mspec; end
      def verify_mocks_for_mspec; end
      def teardown_mocks_for_mspec; end

    end
  end
end
