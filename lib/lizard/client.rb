require "net/http"
require "json"

module Lizard
  class Client
    def initialize(api_key: nil, url: nil)
      @api_key = api_key || ENV["LIZARD_API_KEY"] || Lizard.api_key
      @url = url || ENV["LIZARD_URL"] || Lizard.url
    end

    def send_test_run(data)
      return unless configured?

      payload = { test_run: data }
      uri = URI("#{@url}/api/v1/test_runs")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Accept"] = request["Content-Type"] = "application/json"
      request.body = payload.to_json

      response = http.request(request)
      handle_response(response)
    rescue => e
      puts "❌ Failed to send to Lizard: #{e.message}"
      puts e.backtrace.first(5)
    end

    private

    def configured?
      @api_key && @url
    end

    def handle_response(response)
      if response.code.to_i >= 400 && response.code.to_i < 500
        puts "❌ Lizard API error (#{response.code}): #{response.body}"
      else
        puts "📊 Sent test results to Lizard: #{response.code}"
      end
    end
  end
end