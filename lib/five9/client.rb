# frozen_string_literal: true

require 'singleton'

# I've been liberally using active support stuff throughout my codebase, just because I'm so
# used to rails that I keep forgetting which stuff is active support and which stuff is
# included in ruby by default. So I'm using a few pieces that the rails team has been
# so generous as to include and requiring them here.
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/array/access'
require "active_support/core_ext/hash/indifferent_access"

require 'net/http'
require 'openssl'

require_relative 'client/version'
require_relative 'client/configuration'
require_relative 'client/base'
require_relative 'client/campaign'
require_relative 'client/list'
require_relative 'client/logger'
require_relative 'client/disposition'
require_relative 'client/report'
require_relative 'client/error'

module Five9
  # This class is responsible for providing a reliable interface to
  # send and receive data from Five9's SOAP API, in particular, all
  # the stuff about campaign configuration and such
  module Client
    def self.configure
      yield Configuration.instance || Configuration.default_configuration
    end

    def self.configuration
      Configuration.instance
    end
  end
end
