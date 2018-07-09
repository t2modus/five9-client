# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for getting everything set up
    # that's necessary so that we can make API requests to
    # Five9
    class Configuration
      attr_accessor :url, :login

      def initialize(url, login = nil)
        self.url = URI.parse url
        self.login = login || Login.default_login
      end

      class << self
        def default_configuration
          self.new(ENV['FIVE9_URL'], Login.default_login)
        end
      end
    end
  end
end
