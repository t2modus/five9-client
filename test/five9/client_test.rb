require "test_helper"

class Five9::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Five9::Client::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
