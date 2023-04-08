# frozen_string_literal: true

class Async::Signals::Signal
  Connection = Async::Signals::Connection
  Validator = Async::Signals::Validator

  attr_reader :name, :arg_types, :connections

  def initialize(name, arg_types)
    @name = name
    @arg_types = arg_types

    @validator = Validator.new(self)
    @connections = {}
  end

  # Only 3 ways to connect:
  # some_object.some_signal.connect(receiver) -> receiver#on_some_signal
  # some_object.some_signal.connect(receiver.method(:do_something)) -> receiver#do_something
  # some_object.some_signal.connect(receiver.another_signal) ->  emits receiver#another_signal
  # Blocks, Procs and Lambda are not supported on purpose
  def connect(callable = nil, mode: :direct, one_shot: false)
    @validator.validate_callable!(callable)

    Connection.new(callable, self, mode:, one_shot:).tap { @connections[callable] = _1 }
  end

  def disconnect(callable)
    raise ArgumentError, "given callable is not connected to this signal" if @connections.delete(callable).nil?
  end

  def emit(*args)
    @validator.validate_args!(args)
    notify_subscribers(args)
  end

  def call(...) = emit(...)

  def notify_subscribers(args)
    @connections.values.shuffle.each do |connection|
      connection.call(*args)
    ensure
      connection.disconnect if connection.one_shot?
    end
  end
end
