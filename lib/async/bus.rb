# frozen_string_literal: true

class Async::Bus
  # dry-events is not a dependency of async-tools on purpose.
  # add it to your bundle yourself

  # Semantics:
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

  def log_error(name, e) = Console.logger.warn(self, "Subscriber for #{name.inspect} failed with exception.", e)
end
