# frozen_string_literal: true

class Async::Signals::Signal
  Connection = Async::Signals::Connection
  Validator = Async::Signals::Validator

  attr_reader :name, :arg_types, :connections

  def initialize(name, arg_types)
    @name = name
    @arg_types = arg_types

    @validator = Validator.new(arg_types)
    @connections = Set.new
  end

  def connect(callable = nil, mode: :direct, one_shot: false, &block)
    callable = @validator.validate_callable!(callable, block)

    Connection.new(callable, self, mode:, one_shot:).tap { @connections << _1 }
  end

  def disconnect(callable)
    raise ArgumentError, "given callable is not connected to this signal" if @connections.delete(callable).nil?
  end

  private

  def emit(*args)
    @validator.validate_args!(args)
    notify_subscribers(args)
  end

  def notify_subscribers(args) = @connections.each { _1.call(*args) }
end
