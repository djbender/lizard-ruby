require "test_helper"

class MinitestReporterTest < Minitest::Test
  def setup
    @reporter = Lizard::MinitestReporter.new
  end

  def teardown
    ENV.delete("LIZARD_TEST_MODE")
    ENV.delete("LIZARD_API_KEY")
    ENV.delete("LIZARD_URL")
    ENV.delete("LIZARD_REPORT")
  end

  def test_inherits_from_minitest_statistics_reporter
    assert @reporter.is_a?(Minitest::StatisticsReporter)
  end

  def test_report_method_exists
    assert_respond_to @reporter, :report
  end

  def test_callback_methods_exist
    assert_respond_to @reporter, :before_test
    assert_respond_to @reporter, :after_test
    assert_respond_to @reporter, :before_suite
    assert_respond_to @reporter, :after_suite
  end

  def test_report_sends_to_lizard_when_configured
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"

    client = mock
    client.expects(:send_test_run).once

    Lizard::Client.stubs(:new).returns(client)

    @reporter.stubs(:count).returns(5)
    @reporter.stubs(:total_time).returns(1.5)
    @reporter.stubs(:`).with("git rev-parse HEAD").returns("abc123")
    @reporter.stubs(:`).with("git branch --show-current").returns("main")

    SimpleCov.stubs(:result).returns(mock(covered_percent: 85.0))

    capture_io do
      @reporter.report
    end
  end

  def test_report_handles_nil_simplecov_result
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"

    client = mock
    client.expects(:send_test_run).with(has_entry(:coverage, 0.0))

    Lizard::Client.stubs(:new).returns(client)

    @reporter.stubs(:count).returns(5)
    @reporter.stubs(:total_time).returns(1.5)
    @reporter.stubs(:`).with("git rev-parse HEAD").returns("abc123")
    @reporter.stubs(:`).with("git branch --show-current").returns("main")

    SimpleCov.stubs(:result).returns(nil)

    capture_io do
      @reporter.report
    end
  end

  def test_report_skips_send_when_in_test_mode
    ENV["LIZARD_TEST_MODE"] = "true"
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"

    Lizard::Client.expects(:new).never

    capture_io do
      @reporter.report
    end
  end

  def test_report_skips_send_when_lizard_report_not_true
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "false"

    Lizard::Client.expects(:new).never

    capture_io do
      @reporter.report
    end
  end
end
