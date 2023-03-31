# frozen_string_literal: true

class Async::Signals::Signal
  Connection = Async::Signals::Connection

  attr_reader :name, :arg_types, :connections

  def initialize(name, arg_types)
    @name = name
    @arg_types = arg_types

    @connections = Set.new
  end

  def connect(callable = nil, mode: :direct, one_shot: false, &block)
    callable = validate_callable!(callable, block)

    Connection.new(callable, self, mode:, one_shot:).tap { @connections << _1 }
  end

  def disconnect(callable)
    raise ArgumentError, "given callable is not connected to this signal" if @connections.delete(callable).nil?
  end

  private

  def emit(*args)
    validate_args!(args)
    notify_subscribers(args)
  end

  def validate_args!(args)
    types = args.map(&:class)

    return if types.count == @arg_types.count && types_match?(types)

    raise Async::Signals::EmitError, "expected args: #{@arg_types}. given: #{types}"
  end

  def notify_subscribers(args) = @connections.each { _1.call(*args) }

  def types_match?(types) = types.each.with_index.all? { _1.ancestors.include?(@arg_types[_2]) }

  def validate_callable!(callable, block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    callables = [callable, block]
    raise ArgumentError, "callable OR block must be passed" if callables.all?(&:nil?) || callables.none?(&:nil?)

    callable ||= block

    if !callable.respond_to?(:call) && !callable.is_a?(self.class)
      raise ArgumentError, "callable must respond to #call or be a Signal"
    end

    if callable.is_a?(self.class) && callable.arg_types != @arg_types
      raise ArgumentError,
            "target signal must have similar type signature. Expected: #{@arg_types}. given: #{callable.arg_types}"
    end

    if callable.respond_to?(:arity) && callable.arity != -1 && callable.arity != @arg_types.count
      raise ArgumentError, "callable must have arity of #{@arg_types.count}, given: #{callable.arity}"
    end

    callable
  end
end
