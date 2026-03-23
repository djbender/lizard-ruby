require "test_helper"
require "net/http"
require "yaml"
require "json_schemer"

class ContractTest < Minitest::Test
  SPEC_URL = "https://djbender.github.io/lizard/openapi.yaml"

  def setup
    @spec = fetch_spec
    if @spec.nil?
      msg = "OpenAPI spec not reachable at #{SPEC_URL}"
      ENV["SKIP_CONTRACT_TESTS"] ? skip(msg) : raise(msg)
    end
    @schemas = @spec.dig("components", "schemas")
  end

  def test_rspec_payload_matches_request_schema
    payload = build_rspec_payload
    schemer = schemer_for("CreateTestRunRequest")

    errors = schemer.validate(payload).to_a
    assert_empty errors, "RSpec payload failed validation:\n#{format_errors(errors)}"
  end

  def test_rspec_payload_with_metadata_matches_request_schema
    payload = build_rspec_payload(
      github_run_id: "23419710055",
      github_repository: "djbender/lizard-ruby"
    )
    schemer = schemer_for("CreateTestRunRequest")

    errors = schemer.validate(payload).to_a
    assert_empty errors, "RSpec payload with metadata failed validation:\n#{format_errors(errors)}"
  end

  def test_minitest_payload_matches_request_schema
    payload = build_minitest_payload
    schemer = schemer_for("CreateTestRunRequest")

    errors = schemer.validate(payload).to_a
    assert_empty errors, "Minitest payload failed validation:\n#{format_errors(errors)}"
  end

  def test_success_response_matches_schema
    response = {"status" => "success", "id" => 1}
    schemer = schemer_for("SuccessResponse")

    errors = schemer.validate(response).to_a
    assert_empty errors, "Success response failed validation:\n#{format_errors(errors)}"
  end

  def test_error_response_matches_schema
    response = {"error" => "Invalid API key"}
    schemer = schemer_for("ErrorResponse")

    errors = schemer.validate(response).to_a
    assert_empty errors, "Error response failed validation:\n#{format_errors(errors)}"
  end

  private

  def fetch_spec
    uri = URI(SPEC_URL)
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)
    YAML.safe_load(response.body)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error
    nil
  end

  def build_rspec_payload(github_run_id: nil, github_repository: nil)
    metadata = {}
    metadata["github_run_id"] = github_run_id if github_run_id
    metadata["github_repository"] = github_repository if github_repository

    {
      "test_run" => {
        "commit_sha" => "abc123def456",
        "branch" => "main",
        "ruby_specs" => 42,
        "js_specs" => 0,
        "runtime" => 12.345,
        "coverage" => 95.5,
        "ran_at" => Time.now.iso8601,
        "metadata" => metadata
      }
    }
  end

  def build_minitest_payload(github_run_id: nil, github_repository: nil)
    metadata = {}
    metadata["github_run_id"] = github_run_id if github_run_id
    metadata["github_repository"] = github_repository if github_repository

    {
      "test_run" => {
        "commit_sha" => "abc123def456",
        "branch" => "main",
        "ruby_specs" => 10,
        "js_specs" => 0,
        "runtime" => 3.21,
        "coverage" => 88.0,
        "ran_at" => Time.now.iso8601,
        "metadata" => metadata
      }
    }
  end

  def schemer_for(schema_name)
    schema = @schemas.fetch(schema_name)
    resolved = resolve_refs(schema)
    JSONSchemer.schema(resolved)
  end

  def resolve_refs(node)
    case node
    when Hash
      if node.key?("$ref")
        ref_name = node["$ref"].split("/").last
        resolve_refs(@schemas.fetch(ref_name))
      else
        node.transform_values { |v| resolve_refs(v) }
      end
    when Array
      node.map { |v| resolve_refs(v) }
    else
      node
    end
  end

  def format_errors(errors)
    errors.map { |e| "  #{e["data_pointer"]}: #{e["type"]} — #{e["details"]}" }.join("\n")
  end
end
