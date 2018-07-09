# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for representing credentials
    # for logging in to Five9.
    class Login
      attr_accessor :username, :password

      def initialize(username, password)
        self.username = username
        self.password = password
      end

      def auth_args
        [self.username, self.password]
      end

      class << self
        def default_login
          self.new(ENV['FIVE9_USER'], ENV['FIVE9_PASSWORD'])
        end
      end
    end
  end
end
