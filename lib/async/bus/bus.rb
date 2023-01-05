# frozen_string_literal: true

class Async::Bus::Bus
  attr_reader :name

  EventWrapper = Data.define(:name, :payload, :meta)

  include Console

  def initialize(name: :default, limit: 10)
    @name = name
    @limit = limit

    @subscribers = Hash.new { |hash, key| hash[key] = [] }
  end

  # Blocks if any of output channels is full!
  def publish(nameable_or_event, **payload)
    name, payload = normalize(nameable_or_event, payload)
    wrapper = EventWrapper.new(name, payload,
                               {
                                 bus: self,
                                 published_at: now
                               })
    return if @subscribers[name].empty?

    @subscribers[name].each do |chan|
      publishing_blocked if chan.full?
      chan << wrapper
    end
  end

  # Blocks!
  def subscribe(nameable, callable = nil, &block)
    callable ||= block
    unless callable.respond_to?(:call)
      raise ArgumentError, "callable or block must be provided. callable must respond to :call"
    end

    event_name = normalize(nameable).first

    chan = Async::Channel.new(@limit)
    @subscribers[event_name] << chan
    serve(chan, event_name, callable)
  end

  private

  def normalize(nameable, payload = {})
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

    chan.each do |wrapper|
      delivered_at = now
      wrapper.meta.merge!(delivered_at:, latency: delivered_at - wrapper.meta[:published_at])
      callable.call(wrapper.payload, unsub:, meta: wrapper.meta)
      break if stopped
    end
  end

  def publishing_blocked
    logger.warn(self) { "One of the subscribers is slow, blocking publishing. Event name: #{name}" }
  end

  def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
end
