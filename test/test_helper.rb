require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  enable_coverage :branch

  # at_exit do
  #   SimpleCov.result.format!
  # end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "lizard"
require "minitest/autorun"
require "mocha/minitest"
