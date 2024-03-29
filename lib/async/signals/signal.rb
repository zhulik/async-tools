# frozen_string_literal: true

class Async::Signals::Signal
  Connection = Async::Signals::Connection
  Validator = Async::Signals::Validator

  attr_reader :name, :arg_types, :connections

  def initialize(name, arg_types)
    @name = name
    @arg_types = arg_types

    @validator = Validator.new(arg_types)
    @connections = {}
  end

  def connect(callable = nil, mode: :direct, one_shot: false, &block)
    callable = @validator.validate_callable!(callable, block)

    Connection.new(callable, self, mode:, one_shot:).tap { @connections[callable] = _1 }
  end

  def disconnect(callable)
    raise ArgumentError, "given callable is not connected to this signal" if @connections.delete(callable).nil?
  end

  private

  def emit(*args)
    @validator.validate_args!(args)
    notify_subscribers(args)
  end

  def notify_subscribers(args)
    @connections.values.shuffle.each do |connection|
      connection.call(*args)
    ensure
      connection.disconnect if connection.one_shot?
    end
  end
end
