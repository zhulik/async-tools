# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
end

require "async/tools"

require "async/rspec"
require "async/barrier"

Zeitwerk::Loader.eager_load_all

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| load(f) }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.include_context Async::RSpec::Reactor
  config.include_context Async::RSpec::Leaks
end
