require "minitest"

module Lizard
  class MinitestReporter < Minitest::StatisticsReporter
    def report
      begin
        super
      rescue
        nil
      end
      send_to_lizard if should_report?
    end

    def before_test(_)
    end

    def after_test(_)
    end

    def before_suite(_)
    end

    def after_suite(_)
    end

    private

    def should_report?
      # Don't report during test runs to avoid coverage inconsistency
      return false if ENV["LIZARD_TEST_MODE"]

      # Only report from designated matrix job (if specified)
      # Branch is covered by send tests but LIZARD_TEST_MODE early return above
      # causes SimpleCov to miss the fall-through path
      # :nocov:
      return false if ENV["LIZARD_REPORT"] != "true"
      # :nocov:

      ENV["LIZARD_API_KEY"] && ENV["LIZARD_URL"]
    end

    def send_to_lizard
      data = {
        commit_sha: ENV["GITHUB_SHA"] || `git rev-parse HEAD`.strip,
        branch: ENV["GITHUB_REF_NAME"] || `git branch --show-current`.strip,
        ruby_specs: count,
        js_specs: 0,
        runtime: total_time,
        coverage: extract_coverage,
        ran_at: Time.now.iso8601,
        metadata: github_metadata
      }

      Client.new.send_test_run(data)
    end

    def github_metadata
      meta = {}
      meta[:github_run_id] = ENV["GITHUB_RUN_ID"] if ENV["GITHUB_RUN_ID"]
      meta[:github_repository] = ENV["GITHUB_REPOSITORY"] if ENV["GITHUB_REPOSITORY"]
      meta
    end

    def extract_coverage
      return SimpleCov.result.covered_percent if defined?(SimpleCov) && SimpleCov.result
      0.0
    end
  end
end
