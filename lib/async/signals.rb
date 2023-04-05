# frozen_string_literal: true

module Async::Signals
  class EmitError < ArgumentError; end

  module InstanceMethods
    def emit(name, *args) = send(name).send(:emit, *args)
  end

  def self.extended(base)
    base.include(InstanceMethods)
  end

  def signal(name, *arg_types)
    define_method(name) do
      var_name = "@#{name}"
      return instance_variable_get(var_name) if instance_variable_defined?(var_name)

      instance_variable_set(var_name, Signal.new(name, arg_types))
    end
  end
end
