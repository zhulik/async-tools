# frozen_string_literal: true

class Async::Signals::Connection
  include Async::Logger

  Signal = Async::Signals::Signal

  attr_reader :callable, :mode, :signal

  def initialize(callable, signal, mode:, one_shot:)
    @callable = callable
    @signal = signal
    @mode = mode
    @one_shot = one_shot
  end

  def one_shot? = @one_shot

  def call(...)
    return @callable.send(:emit, ...) if @callable.is_a?(Signal)

    @callable.call(...)
  rescue StandardError => e
    warn(e)
  ensure
    disconnect if one_shot?
  end

  def disconnect = @signal.disconnect(@callable)

  def equal?(...) = @callable.equal?(...)
  def eql?(...) = @callable.eql?(...)
  def ==(...) = @callable.==(...)
  def hash(...) = @callable.hash(...)
end
