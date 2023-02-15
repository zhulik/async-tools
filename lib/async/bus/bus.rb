# frozen_string_literal: true

class Async::Bus::Bus
  attr_reader :name

  include Console

  def initialize(name: :default, limit: 10)
    @name = name
    @limit = limit
    @closed = false

    @subscribers = Hash.new { |hash, key| hash[key] = [] }
  end

  # Blocks if any of output channels is full!
  def publish(nameable_or_event, **payload)
    check_if_open!
    name, payload = normalize(nameable_or_event, payload)

    subs = @subscribers[name]
    return if subs.empty?

    subs.each do |chan|
      publishing_blocked if chan.full?
      chan << [name, payload]
    end
    Async::Task.current.yield
  end

  # Blocks!
  def subscribe(nameable, callable = nil, &block)
    check_if_open!
    callable ||= block
    unless callable.respond_to?(:call)
      raise ArgumentError, "callable or block must be provided. callable must respond to :call"
    end

    event_name = normalize(nameable).first

    chan = Async::Channel.new(@limit)
    @subscribers[event_name] << chan
    serve(chan, event_name, callable)
  end

  def async_subscribe(*, **, &) = Async { subscribe(*, **, &) }
  def on_event(&block) = @on_event_callback = block

  def close
    return if @closed

    @closed = true

    @subscribers.values.flatten.each(&:close)
    @subscribers.clear
  end

  private

  def normalize(nameable, payload = nil)
    return [nameable, payload] if nameable.is_a?(Symbol)
    return [nameable.to_sym, payload] if nameable.is_a?(String)
    return [nameable.event_name.to_sym, nameable] if nameable.respond_to?(:event_name)

    n = nameable[:event_name] || nameable["event_name"]
    return [n.to_sym, nameable] if n

    raise ArgumentError, "cannot infer event name from #{nameable.inspect}"
  end

  def serve(chan, event_name, callable)
    stopped = false
    unsub = lambda {
      chan.close
      stopped = true
      @subscribers[event_name].delete(chan)
    }

    chan.each do |name, payload|
      @on_event_callback&.call(wrapper)
      callable.call(payload, unsub:, meta: { bus: self })
      break if stopped
    end
  end

  def publishing_blocked
    logger.warn(self) { "One of the subscribers is slow, blocking publishing. Event name: #{name}" }
  end

  def check_if_open!
    raise "Bus is closed" if @closed
  end
end
