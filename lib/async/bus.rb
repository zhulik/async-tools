# frozen_string_literal: true

class Async::Bus
  include Async::Logger
  # A tiny wrapper around ac ActiveSupport::Notifications

  # BLOCKING unless subscribers run in tasks
  def publish(name, *args, **params)
    ActiveSupport::Notifications.instrument(name, payload: (args.first || params))
  rescue StandardError => e
    log_error(name, e)
  end

  # NON-BLOCKING
  def subscribe(pattern)
    ActiveSupport::Notifications.subscribe(pattern) do |name, _start, _finish, _id, params|
      yield params[:payload], name
    end
  end

  # NON-BLOCKING, runs subscriber in a task
  def async_subscribe(pattern, parent: Async::Task.current)
    subscribe(pattern) do |event|
      parent.async  do
        yield(event)
      rescue StandardError => e
        log_error(pattern, e)
      end
    end
  end

  def convert(from_event, to_event) = subscribe(from_event) { publish(to_event, **yield(_1)) }

  private

  def log_error(name, e) = warn("Subscriber for #{name.inspect} failed with exception.", e)
end
