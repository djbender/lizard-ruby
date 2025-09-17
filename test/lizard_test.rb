require "test_helper"

class LizardTest < Minitest::Test
  def teardown
    Lizard.api_key = nil
    Lizard.url = nil
  end

  def test_configure_sets_api_key_and_url
    Lizard.configure do |config|
      config.api_key = "test_key"
      config.url = "https://test.example.com"
    end

    assert_equal "test_key", Lizard.api_key
    assert_equal "https://test.example.com", Lizard.url
  end

  def test_configure_without_block
    result = Lizard.configure
    assert_nil result
  end

  def test_api_key_accessor
    Lizard.api_key = "new_api_key"
    assert_equal "new_api_key", Lizard.api_key

    Lizard.api_key = nil
    assert_nil Lizard.api_key
  end

  def test_url_accessor
    Lizard.url = "https://new.example.com"
    assert_equal "https://new.example.com", Lizard.url

    Lizard.url = nil
    assert_nil Lizard.url
  end

  def test_error_class_inheritance
    error = Lizard::Error.new("test message")
    assert_instance_of Lizard::Error, error
    assert_kind_of StandardError, error
    assert_equal "test message", error.message
  end
end
