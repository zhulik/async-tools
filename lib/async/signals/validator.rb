# frozen_string_literal: true

class Async::Signals::Validator
  Signal = Async::Signals::Signal

  def initialize(signal)
    @signal = signal
  end

  def validate_args!(args)
    types = args.map(&:class)

    return if types.count == @signal.arg_types.count && types_match?(types)

    raise Async::Signals::EmitError, "expected args: #{@signal.arg_types}. given: #{types}"
  end

  def validate_callable!(callable)
    callable = validate_callable_type!(callable)
    validate_signal_arity!(callable) if callable.is_a?(Signal)
  end

  def validate_callable_type!(callable)
    return callable if callable.is_a?(Signal) || callable.is_a?(Method)

    method_name = "on_#{@signal.name}".to_sym
    return callable.method(method_name) if callable.respond_to?(method_name)

    raise ArgumentError, "callable must be a Signal, a Method, or must respond to #{method_name}"
  end

  private

  def types_match?(types) = types.each.with_index.all? { _1.ancestors.include?(@signal.arg_types[_2]) }

  def validate_signal_arity!(signal)
    return if signal.arg_types == @signal.arg_types

    raise ArgumentError,
          "target signal must have similar type signature. Expected: #{@signal.arg_types}. given: #{signal.arg_types}"
  end
end
