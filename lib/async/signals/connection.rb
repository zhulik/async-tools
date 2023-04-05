# frozen_string_literal: true

class Async::Signals::Connection
  include Async::Logger

  attr_reader :callable, :mode, :signal

  def initialize(callable, signal, mode:, one_shot:, parent: Async::Task.current)
    @callable = callable
    @signal = signal
    @mode = mode
    @one_shot = one_shot

    @parent = parent

    return if mode == :direct

    @channel = Async::Channel.new(Float::INFINITY)
    @task = parent.async { read_channel }
  end

  def one_shot? = @one_shot

  def call(*args, force_direct: false)
    return direct_call(args) if mode == :direct || force_direct

    @channel << args
  end

  def disconnect
    @signal.disconnect(@callable)
    @channel&.close
    @task&.wait
  end

  def direct_call(args)
    return @callable.send(:emit, *args) if @callable.respond_to?(:emit, true)

    @callable.call(*args)
  rescue StandardError => e
    warn(e)
  end

  def read_channel
    @channel.each { call(*_1, force_direct: true) }
  end
end
