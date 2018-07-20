# frozen_string_literal: true

require 'test_helper'

module Five9
  module Client
    class BaseTest < Minitest::Test
      def test_making_a_request_without_configuring_the_client_raises_an_error
        clear_configuration
        assert_raises Five9::Client::Error do
          Five9::Client::Base.request(nil)
        end
      end

      def test_making_an_invalid_request_results_in_an_error_being_logged
        Net::HTTP.any_instance
                 .stubs(:request)
                 .returns(OpenStruct.new(body: '<xml><faultcode>This is invalid XML from Five9</faultcode></xml>'))
        Five9::Client::Logger.expects(:error).once
        setup_configuration(url: 'blah')
        Five9::Client::Base.request(nil)
      end
    end
  end
end
