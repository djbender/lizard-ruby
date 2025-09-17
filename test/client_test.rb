require "test_helper"

class ClientTest < Minitest::Test
  def teardown
    Lizard.api_key = nil
    Lizard.url = nil
    ENV.delete("LIZARD_API_KEY")
    ENV.delete("LIZARD_URL")
  end

  def test_initialize_accepts_parameters
    client = Lizard::Client.new(api_key: "test_key", url: "https://test.example.com")

    assert_instance_of Lizard::Client, client
  end

  def test_initialize_with_lizard_module_fallback
    Lizard.api_key = "module_key"
    Lizard.url = "https://module.example.com"

    client = Lizard::Client.new

    assert_instance_of Lizard::Client, client
  end

  def test_send_test_run_returns_early_when_not_configured
    client = Lizard::Client.new(api_key: nil, url: nil)
    result = client.send_test_run({test: "data"})

    assert_nil result
  end

  def test_send_test_run_success
    response = mock
    response.stubs(:code).returns("200")

    http = mock
    http.stubs(:use_ssl=)
    http.stubs(:request).returns(response)

    Net::HTTP.stubs(:new).returns(http)

    client = Lizard::Client.new(api_key: "test_key", url: "https://test.example.com")

    out, _err = capture_io do
      client.send_test_run({test: "data"})
    end

    assert_includes out, "📊 Sent test results to Lizard: 200"
  end

  def test_send_test_run_handles_exceptions
    Net::HTTP.stubs(:new).raises(StandardError.new("Connection failed"))

    client = Lizard::Client.new(api_key: "test_key", url: "https://test.example.com")

    out, _err = capture_io do
      client.send_test_run({test: "data"})
    end

    assert_includes out, "❌ Failed to send to Lizard: Connection failed"
  end

  def test_send_test_run_handles_4xx_errors
    response = mock
    response.stubs(:code).returns("400")
    response.stubs(:body).returns("Bad Request")

    http = mock
    http.stubs(:use_ssl=)
    http.stubs(:request).returns(response)

    Net::HTTP.stubs(:new).returns(http)

    client = Lizard::Client.new(api_key: "test_key", url: "https://test.example.com")

    out, _err = capture_io do
      client.send_test_run({test: "data"})
    end

    assert_includes out, "❌ Lizard API error (400): Bad Request"
  end

  def test_send_test_run_sets_ssl_for_https_url
    response = mock
    response.stubs(:code).returns("200")

    http = mock
    http.expects(:use_ssl=).with(true)
    http.stubs(:request).returns(response)

    Net::HTTP.stubs(:new).returns(http)

    client = Lizard::Client.new(api_key: "test_key", url: "https://test.example.com")

    capture_io do
      client.send_test_run({test: "data"})
    end
  end

  def test_send_test_run_sets_ssl_false_for_http_url
    response = mock
    response.stubs(:code).returns("200")

    http = mock
    http.expects(:use_ssl=).with(false)
    http.stubs(:request).returns(response)

    Net::HTTP.stubs(:new).returns(http)

    client = Lizard::Client.new(api_key: "test_key", url: "http://test.example.com")

    capture_io do
      client.send_test_run({test: "data"})
    end
  end

  def test_initialize_with_environment_variables
    ENV["LIZARD_API_KEY"] = "env_key"
    ENV["LIZARD_URL"] = "https://env.example.com"

    client = Lizard::Client.new

    assert_instance_of Lizard::Client, client
  end
end
