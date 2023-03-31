# frozen_string_literal: true

class Async::Signals::Validator
  Signal = Async::Signals::Signal

  def initialize(arg_types)
    @arg_types = arg_types
  end

  def validate_args!(args)
    types = args.map(&:class)

    return if types.count == @arg_types.count && types_match?(types)

    raise Async::Signals::EmitError, "expected args: #{@arg_types}. given: #{types}"
  end

  def validate_callable!(callable, block)
    get_signal_or_callable!(callable, block).tap do |callable_or_signal|
      validate_callable_type!(callable_or_signal)
      validate_signal_arity!(callable_or_signal) if callable_or_signal.is_a?(Signal)
      validate_arity!(callable_or_signal) if callable_or_signal.respond_to?(:arity)
    end
  end

  private

  def types_match?(types) = types.each.with_index.all? { _1.ancestors.include?(@arg_types[_2]) }

  def get_signal_or_callable!(callable, block)
    callables = [callable, block]
    return callable || block if callables.count(&:nil?) == 1

    raise ArgumentError, "callable OR block must be passed"
  end

  def validate_callable_type!(callable)
    return if callable.respond_to?(:call) || callable.is_a?(Signal)

    raise ArgumentError, "callable must respond to #call or be a Signal"
  end

  def validate_signal_arity!(signal)
    return if signal.arg_types == @arg_types

    raise ArgumentError,
          "target signal must have similar type signature. Expected: #{@arg_types}. given: #{signal.arg_types}"
  end

  def validate_arity!(callable)
    return if callable.arity == -1 || callable.arity == @arg_types.count

    raise ArgumentError, "callable must have arity of #{@arg_types.count}, given: #{callable.arity}"
  end
end
