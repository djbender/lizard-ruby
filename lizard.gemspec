require_relative "lib/lizard/version"

Gem::Specification.new do |spec|
  spec.name = "lizard"
  spec.version = Lizard::VERSION
  spec.authors = ["Derek Bender"]

  spec.summary = "Test result reporter for Lizard API"
  spec.description = "A gem that reports test results from Minitest and RSpec to the Lizard API service"
  spec.homepage = "https://github.com/djbender/lizard"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "mocha", "~> 2.0"
end
