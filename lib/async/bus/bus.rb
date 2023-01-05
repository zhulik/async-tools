# frozen_string_literal: true

class Async::Bus::Bus
  attr_reader :name

  include Console

  def initialize(name: :default, limit: 10)
    @name = name
    @limit = limit

    @subscribers = Hash.new { |hash, key| hash[key] = [] }
  end

  # Blocks if any of output channels is full!
  def publish(nameable_or_event, **payload)
    name, payload = normalize(nameable_or_event, payload)
    return if @subscribers[name].empty?

    @subscribers[name].each do |chan|
      logger.warn(self) { "One of the subscribers is slow, blocking publishing. Event name: #{name}" } if chan.full?
      chan << payload
      # rescue Async::Channel::ChannelClosedError
      #   # It's ok, some of the subscribers unsubscribed
      #   pp("!!!")
      #   next
    end
  end

  # Blocks!
  def subscribe(nameable, callable = nil, &block)
    callable ||= block
    unless callable.respond_to?(:call)
      raise ArgumentError, "callable or block must be provided. callable must respond to :call"
    end

    event_name, = normalize(nameable).first

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

    raise ArgumentError, "cannod infer event name from #{nameable.inspect}"
  end

  def serve(chan, event_name, callable)
    stopped = false
    unsub = lambda {
      chan.close
      stopped = true
      @subscribers[event_name].delete(chan)
    }
    meta = { bus: self }

    chan.each do |event|
      callable.call(event, unsub:, meta:)
      break if stopped
    end
  end
end
