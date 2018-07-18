# frozen_string_literal: true

module Webmock
  module Five9
    module TestHelper
      def webmock_file(filename)
        "test/webmock-requests/#{filename}.xml"
      end

      def stub_action(action, file)
        stub_request(:post, stubbed_url).to_return(
          body: File.read(file)
        )
      end

      private
        def stubbed_url
          url = ::Five9::Client.configuration.url
          "https://#{url.host}:#{url.port}#{url.path}"
        end
    end
  end
end
