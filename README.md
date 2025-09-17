# Lizard

A Ruby gem that reports test results from Minitest and RSpec to the Lizard API service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lizard'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lizard

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/djbender/lizard.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).