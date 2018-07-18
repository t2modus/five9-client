# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'five9/client'

require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'
require 'byebug'
require 'webmock/minitest'
require 'timecop'

require_relative 'webmock_test_helper'

module Minitest
  class Test
    include Webmock::Five9::TestHelper

    def clear_configuration
      Five9::Client.configuration.clear
    end

    def setup_configuration(url: nil, username: nil, password: nil)
      Five9::Client.configure do |config|
        config.url = url || 'https://www.google.com'
        config.username = username || 'andrew'
        config.password = password || 'this is a password'
      end
    end
  end
end
