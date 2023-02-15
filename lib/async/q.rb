# frozen_string_literal: true

require "forwardable"

require "async/notification"

class Async::Q
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

  def count = @items.count
  def size = @items.size
  def length = @items.length

  def full? = size >= @limit
  def empty? = @items.empty?

  def expand(n) = resize(limit + n)
  def shrink(n) = resize(limit - n)
  def <<(item) = enqueue(item)

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

  def enqueue(item)
    @free_notification.wait while full?

    @items.push(item)
    @any_notification.signal
  end

  def enqueue_all(items) = items.each { |item| enqueue(item) }

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
end
