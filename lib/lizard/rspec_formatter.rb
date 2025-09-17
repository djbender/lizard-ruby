require "rspec/core"
require "rspec/core/formatters/base_formatter"

module Lizard
  class RSpecFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :dump_summary

    def initialize(output)
      super
      @start_time = Time.now
    end

    def dump_summary(summary)
      return unless should_report?

      data = {
        commit_sha: ENV["GITHUB_SHA"] || `git rev-parse HEAD`.strip,
        branch: ENV["GITHUB_REF_NAME"] || `git branch --show-current`.strip,
        ruby_specs: summary.example_count,
        js_specs: 0,
        runtime: summary.duration,
        coverage: extract_coverage,
        ran_at: Time.now.iso8601
      }

      Client.new.send_test_run(data)
    end

    private

    def should_report?
      # Don't report during test runs to avoid coverage inconsistency
      return false if ENV["LIZARD_TEST_MODE"]
      ENV["LIZARD_API_KEY"] && ENV["LIZARD_URL"]
    end

    def extract_coverage
      return SimpleCov.result.covered_percent if defined?(SimpleCov) && SimpleCov.result
      0.0
    end
  end
end