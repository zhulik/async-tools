# frozen_string_literal: true

class Async::Bus
  include Async::Logger
  # dry-events is not a dependency of async-tools on purpose.
  # add it to your bundle yourself

  # Semantics:
  # - Lazily registeres events
  # - Synchronous by default
  # - Catches exceptions in subscribers, logs them
  def initialize(name)
    @name = name
    @w = Class.new.include(Dry::Events::Publisher[name]).new
  end

  # BLOCKING unless subscribers run in tasks
  def publish(name, *args, **params)
    @w.register_event(name)
    @w.publish(name, payload: (args.first || params))
  rescue StandardError => e
    log_error(name, e)
  end

  # NON-BLOCKING
  def subscribe(name)
    @w.register_event(name)
    @w.subscribe(name) { yield(_1[:payload]) }
  end

  # NON-BLOCKING, runs subscriber in a task
  def async_subscribe(name, parent: Async::Task.current)
    subscribe(name) do |event|
      parent.async  do
        yield(event)
      rescue StandardError => e
        log_error(name, e)
      end
    end
  end

  def convert(from_event, to_event) = subscribe(from_event) { publish(to_event, **yield(_1)) }

  private

  def log_error(name, e) = warn("Subscriber for #{name.inspect} failed with exception.", e)
end
