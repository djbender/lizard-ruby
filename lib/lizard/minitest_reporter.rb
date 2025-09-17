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
        ran_at: Time.now.iso8601
      }

      Client.new.send_test_run(data)
    end

    def extract_coverage
      return SimpleCov.result.covered_percent if defined?(SimpleCov) && SimpleCov.result
      0.0
    end
  end
end
