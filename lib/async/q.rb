# frozen_string_literal: true

require "forwardable"

require "async/notification"

module Async
  class Q
    extend Forwardable

    attr_reader :items, :limit

    def initialize(limit = Float::INFINITY, items: [], parent: nil)
      @limit = limit || Float::INFINITY
      @parent = parent

      raise ArgumentError, "Items size is greter than limit: #{items.count} > #{@limit}" if items.count > @limit

      @items = items
      @any_notification = Async::Notification.new
      @free_notification = Async::Notification.new
    end

    %i[size count empty? length].each do |method|
      def_delegator :@items, method, method
    end

    def full?
      size >= @limit
    end

    def resize(new_limit)
      if new_limit > @limit
        @limit = new_limit
        @free_notification.signal
      elsif new_limit <= 0
        raise ArgumentError, "Limit cannot be <= 0: #{new_limit}"
      elsif size > new_limit
        raise ArgumentError, "New limit cannot be lower than the current size: #{size} > #{new_limit}"
      else
        @limit = new_limit
      end
    end

    def_delegator :self, :resize, :scale

    def expand(n)
      resize(limit + n)
    end

    def shrink(n)
      resize(limit - n)
    end

    def enqueue(item)
      @free_notification.wait while full?

      @items.push(item)
      @any_notification.signal
    end

    def enqueue_all(items)
      items.each { |item| enqueue(item) }
    end

    def_delegator :self, :enqueue, :<<

    def dequeue
      @any_notification.wait while empty?

      item = @items.shift

      @free_notification.signal

      item
    end

    def each
      while item = dequeue # rubocop:disable Lint/AssignmentInCondition
        yield(item)
      end
    end

    def async(parent: (@parent || Task.current), &block)
      each do |item|
        parent.async(item, &block)
      end
    end

    def_delegator :self, :full?, :limited?
  end
end
