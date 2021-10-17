# Async::Tools

A set of useful [Async](github.com/socketry/async) tools.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-tools'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install async-tools

## Usage

**More docs coming soon.**

### Classes

#### Async::Q

A drop-in replacement for `Async::Queue` and `Async::LimitedQueue`. Can work as limited or unlimited queue depending on
initializer arguments. Can be scaled up and down when is in the limited mode.

#### Async::Channel

A thin wrapper around Async::Q that acts like a Go channel. Can be user for delivering messages and exceptions(using `#error` method). Exceptions are being reraised in `#dequeue`, `#each` and `#async`. Can be closed. After being closed automatically stops accepting new messages and schedules graceful stop of all consumers. Awaiing `#each` or `#async` will return, `#dequeue` will raise `ChannelClosedError`.

#### Async::WorkerPool

A thin wrapper around `Async::Channel` and `Async::Semaphore`. WorkerPool can be used to perform concurrent actions with
limited strictly limited concurrency.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/async-tools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/async-tools/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Async::Tools project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/async-tools/blob/main/CODE_OF_CONDUCT.md).
