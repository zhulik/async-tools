# frozen_string_literal: true

# Threading is not supported!
module Async::Bus
  class << self
    def get(name = :default)
      @buses ||= {}
      @buses[name] ||= Bus.new(name:)
      @buses[name]
    end
  end
end
