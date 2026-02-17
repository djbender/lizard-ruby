# Lizard

A Ruby gem that reports test results from Minitest and RSpec to the Lizard API service.

## Supported Ruby Versions

- Ruby 3.2
- Ruby 3.3
- Ruby 3.4
- Ruby 4.0

## Installation

Configure Bundler to use GitHub Packages:

```bash
bundle config https://rubygems.pkg.github.com/djbender USERNAME:TOKEN
```

Then add to your Gemfile:

```ruby
source "https://rubygems.pkg.github.com/djbender" do
  gem "lizard"
end
```

And run:

    $ bundle install

Or install it directly:

    $ gem install lizard --source https://USERNAME:TOKEN@rubygems.pkg.github.com/djbender

## Usage

### Configuration

Configure the gem with your Lizard API credentials:

```ruby
Lizard.configure do |config|
  config.api_key = "your_api_key"
  config.url = "https://your-lizard-instance.com"
end
```

Alternatively, you can use environment variables:

```bash
export LIZARD_API_KEY="your_api_key"
export LIZARD_URL="https://your-lizard-instance.com"
```

### Minitest

Add the reporter to your test helper:

```ruby
require 'lizard'

Minitest.reporter = Lizard::MinitestReporter.new
```

### RSpec

Add the formatter to your `.rspec` file:

```
--require lizard
--format Lizard::RSpecFormatter
```

Or configure it in your `spec_helper.rb`:

```ruby
require 'lizard'

RSpec.configure do |config|
  config.add_formatter(Lizard::RSpecFormatter)
end
```

## Data Sent

The gem reports the following data to the Lizard API:

- `commit_sha`: Git commit SHA (from `GITHUB_SHA` environment variable or `git rev-parse HEAD`)
- `branch`: Git branch name (from `GITHUB_REF_NAME` environment variable or `git branch --show-current`)
- `ruby_specs`: Number of tests/examples run
- `js_specs`: Always 0 (for compatibility)
- `runtime`: Test execution time
- `coverage`: Code coverage percentage (if SimpleCov is available)
- `ran_at`: Timestamp when tests were run

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`.

### Releasing

1. Bump the version in `lib/lizard/version.rb`
2. Commit the version bump and push to `main`
3. Tag the commit: `git tag vX.Y.Z`
4. Push the tag: `git push origin vX.Y.Z`

Pushing the tag triggers a GitHub Actions workflow that builds the gem, publishes it to GitHub Packages, and creates a GitHub Release with auto-generated notes.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/djbender/lizard-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
