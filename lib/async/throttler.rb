# frozen_string_literal: true

# inspired by https://github.com/negativecode/vines/blob/master/lib/vines/token_bucket.rb
class Async::Throttler
  def initialize(capacity, rate, parent: Async::Task.current)
    raise ArgumentError, "capacity must be > 0" unless capacity.positive?
    raise ArgumentError, "rate must be > 0" unless rate.positive?

    @capacity = capacity
    @tokens = capacity
    @rate = rate
    @parent = parent

    @timestamp = Time.new
  end

  def wait(timeout: 0, &)
    with_timeout(timeout) do
      while @tokens < 1
        fill!
        sleep(1.0 / @rate)
      end
    end

    @tokens -= 1
  end

  def async(parent: @parent, &)
    wait
    parent.async(&)
  end

  private

  def with_timeout(timeout, &)
    return yield if timeout.zero?

    Fiber.scheduler.with_timeout(timeout, &)
  end

  def fill!
    return if @tokens >= @capacity

    now = Time.new
    @tokens += @rate * (now - @timestamp)
    @tokens = @capacity if @tokens > @capacity
    @timestamp = now
  end
end
