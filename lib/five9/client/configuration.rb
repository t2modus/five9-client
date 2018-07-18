# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for getting everything set up
    # that's necessary so that we can make API requests to
    # Five9
    class Configuration
      include ::Singleton

      attr_reader :url
      attr_accessor :username, :password

      def initialize(url = nil, username = nil, password = nil)
        if url.nil? && username.nil? && password.nil?
          self.set_to_default_configuration
        else
          self.url = url
          self.username = username
          self.password = password
        end
      end

      # This method is largely used in testing, but could theoretically be useful elsewhere so
      # I won't make it private
      def clear
        self.url = nil
        self.username = nil
        self.password = nil
      end

      def url=(v)
        @url = v.present? ? URI.parse(v) : nil
      end

      def present?
        self.url.present? && self.username.present? && self.password.present?
      end

      def set_to_default_configuration
        self.url = ENV['FIVE9_URL']
        self.username = ENV['FIVE9_USER']
        self.password = ENV['FIVE9_PASSWORD']
      end

      class << self
        def default_configuration
          new(ENV['FIVE9_URL'], ENV['FIVE9_USER'], ENV['FIVE9_PASSWORD'])
        end
      end
    end
  end
end
