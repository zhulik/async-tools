# frozen_string_literal: true

class Async::Signals::Connection
  attr_reader :callable, :mode, :signal

  def initialize(callable, signal, mode:, one_shot:)
    @callable = callable
    @signal = signal
    @mode = mode
    @one_shot = one_shot
  end

  def one_shot? = @one_shot

  def call(...)
    @callable.call(...)
    disconnect if one_shot?
  end

  def disconnect = @signal.disconnect(self)

  def equal?(...) = @callable.equal?(...)
  def eql?(...) = @callable.eql?(...)
  def ==(...) = @callable.==(...)
  def hash(...) = @callable.hash(...)
end
