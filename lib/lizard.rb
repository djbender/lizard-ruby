require_relative "lizard/version"
require_relative "lizard/client"
require_relative "lizard/minitest_reporter"

begin
  require_relative "lizard/rspec_formatter"
rescue LoadError
  # RSpec not available
end

module Lizard
  class Error < StandardError; end

  class << self
    attr_accessor :api_key, :url

    def configure
      yield(self) if block_given?
    end
  end
end