# frozen_string_literal: true

module Async::Logger
  [:debug, :info, :warn, :error, :fatal].each do |name|
    define_method(name) do |*args, &block|
      info = respond_to?(:logger_info, true) ? logger_info : nil

      Console.logger.public_send(name, self, info, *args, &block)
    end
  end
end
