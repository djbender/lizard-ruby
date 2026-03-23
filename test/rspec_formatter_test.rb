require "test_helper"

class RSpecFormatterTest < Minitest::Test
  LIZARD_ENV_KEYS = %w[LIZARD_TEST_MODE LIZARD_API_KEY LIZARD_URL LIZARD_REPORT GITHUB_RUN_ID GITHUB_REPOSITORY].freeze

  def setup
    @original_env = LIZARD_ENV_KEYS.to_h { |k| [k, ENV[k]] }
    @output = StringIO.new
    @formatter = Lizard::RSpecFormatter.new(@output)
  end

  def teardown
    LIZARD_ENV_KEYS.each { |k| ENV[k] = @original_env[k] }
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
    ENV.delete("LIZARD_TEST_MODE")
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"

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

  def test_dump_summary_includes_github_metadata_when_env_vars_present
    ENV.delete("LIZARD_TEST_MODE")
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"
    ENV["GITHUB_RUN_ID"] = "23419710055"
    ENV["GITHUB_REPOSITORY"] = "djbender/lizard-ruby"

    expected_metadata = {github_run_id: "23419710055", github_repository: "djbender/lizard-ruby"}

    client = mock
    client.expects(:send_test_run).with(has_entry(:metadata, expected_metadata))

    Lizard::Client.stubs(:new).returns(client)

    @formatter.stubs(:`).with("git rev-parse HEAD").returns("abc123")
    @formatter.stubs(:`).with("git branch --show-current").returns("main")

    summary = mock
    summary.stubs(:example_count).returns(10)
    summary.stubs(:duration).returns(2.5)

    SimpleCov.stubs(:result).returns(mock(covered_percent: 90.0))

    @formatter.dump_summary(summary)
  end

  def test_dump_summary_sends_empty_metadata_without_github_env_vars
    ENV.delete("LIZARD_TEST_MODE")
    ENV.delete("GITHUB_RUN_ID")
    ENV.delete("GITHUB_REPOSITORY")
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"

    client = mock
    client.expects(:send_test_run).with(has_entry(:metadata, {}))

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
    ENV.delete("LIZARD_TEST_MODE")
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "true"

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

  def test_dump_summary_returns_early_when_lizard_report_not_true
    ENV["LIZARD_API_KEY"] = "test_key"
    ENV["LIZARD_URL"] = "https://test.example.com"
    ENV["LIZARD_REPORT"] = "false"

    Lizard::Client.expects(:new).never

    summary = mock
    @formatter.dump_summary(summary)
  end
end
