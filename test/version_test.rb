require "test_helper"

class VersionTest < Minitest::Test
  def test_version_constant_exists
    assert_equal "0.2.0", Lizard::VERSION
  end
end
