# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-03-23

### Added

- Metadata support for test reports (#34)
- Lizard test reporting in CI and Minitest reporter plugin in test_helper (#30)

### Removed

- Ruby 3.2 support; minimum is now 3.3 (#20)

## [0.1.0] - 2026-02-16

### Added

- Minitest reporter and RSpec formatter
- API client for Lizard service
- `LIZARD_REPORT` env var to control reporting
- CI workflow with Ruby 3.3–4.0 + head matrix
- StandardRB linting
- Dependabot for bundler and GitHub Actions
- Release workflow publishing to GitHub Packages with GitHub Releases
- SimpleCov + Codecov integration

[Unreleased]: https://github.com/djbender/lizard-ruby/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/djbender/lizard-ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/djbender/lizard-ruby/releases/tag/v0.1.0
