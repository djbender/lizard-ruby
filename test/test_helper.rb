require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  enable_coverage :branch

  at_exit do
    SimpleCov.result.format! # default
    puts ""
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "lizard"
require "minitest/autorun"
require "mocha/minitest"

ENV["LIZARD_TEST_MODE"] = "true" unless ENV["LIZARD_REPORT"] == "true"

Minitest.extensions << "lizard"

module Minitest
  def self.plugin_lizard_init(options)
    reporter << Lizard::MinitestReporter.new(options[:io], options)
  end
end
