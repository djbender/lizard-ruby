require "test_helper"

class RSpecFormatterTest < Minitest::Test
  def setup
    @output = StringIO.new
    @formatter = Lizard::RSpecFormatter.new(@output)
  end

  def teardown
    ENV.delete("LIZARD_TEST_MODE")
    ENV.delete("LIZARD_API_KEY")
    ENV.delete("LIZARD_URL")
  end

  def test_inherits_from_rspec_base_formatter
    assert @formatter.is_a?(RSpec::Core::Formatters::BaseFormatter)
  end

  def test_dump_summary_method_exists
    assert_respond_to @formatter, :dump_summary
  end

  def test_initialize_accepts_output_parameter
    formatter = Lizard::RSpecFormatter.new(StringIO.new)

    assert_instance_of Lizard::RSpecFormatter, formatter
  end

  def test_dump_summary_sends_to_lizard_when_configured
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"

    client = mock
    client.expects(:send_test_run).once

    Lizard::Client.stubs(:new).returns(client)

    @formatter.stubs(:`).with("git rev-parse HEAD").returns("abc123")
    @formatter.stubs(:`).with("git branch --show-current").returns("main")

    summary = mock
    summary.stubs(:example_count).returns(10)
    summary.stubs(:duration).returns(2.5)

    SimpleCov.stubs(:result).returns(mock(covered_percent: 90.0))

    @formatter.dump_summary(summary)
  end

  def test_dump_summary_handles_nil_simplecov_result
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"

    client = mock
    client.expects(:send_test_run).with(has_entry(:coverage, 0.0))

    Lizard::Client.stubs(:new).returns(client)

    @formatter.stubs(:`).with("git rev-parse HEAD").returns("abc123")
    @formatter.stubs(:`).with("git branch --show-current").returns("main")

    summary = mock
    summary.stubs(:example_count).returns(10)
    summary.stubs(:duration).returns(2.5)

    SimpleCov.stubs(:result).returns(nil)

    @formatter.dump_summary(summary)
  end

  def test_dump_summary_returns_early_when_in_test_mode
    ENV["LIZARD_TEST_MODE"] = "true"
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"

    Lizard::Client.expects(:new).never

    summary = mock
    @formatter.dump_summary(summary)
  end
end