require "test_helper"

class Five9::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Five9::Client::VERSION
  end

  def test_that_it_can_be_configured
    Five9::Client.configure do |config|
      config.url = 'https://www.google.com'
      config.username = 'andrew'
      config.password = 'ireallysuckatcomingupwithpasswords'
    end
    assert_equal URI.parse('https://www.google.com'), Five9::Client.configuration.url
    assert_equal 'andrew', Five9::Client.configuration.username
    assert_equal 'ireallysuckatcomingupwithpasswords', Five9::Client.configuration.password
  end
end
