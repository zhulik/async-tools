# frozen_string_literal: true

module Async
  class ResultNotification
    extend Forwardable

    def initialize
      @channel = Async::Channel.new
    end

    def signal(item = nil)
      @channel << (block_given? ? yield : item)
    rescue Async::Stop, StandardError => e
      @channel.error(e)
    end

    def_delegator :@channel, :dequeue, :wait
  end
end
