# frozen_string_literal: true

class Async::Channel
  extend Forwardable

  attr_reader :subscribers

  class Error < StandardError; end

  class ChannelClosedError < Error; end

  def initialize(limit = 1, **options)
    @queue = Async::Q.new(limit, **options)
    @subscribers = 0

    @parent = options[:parent]
    @closed = false
  end

  def_delegators :@queue, :count, :empty?, :length, :size
  def_delegator :self, :enqueue, :<<

  def enqueue(message)
    check_channel_writeable!

    @queue << [:message, message]
  end

  def enqueue_all(messages)
    check_channel_writeable!

    @queue.enqueue_all(messages.map { |message| [:message, message] })
  end

  def error(e)
    check_channel_writeable!

    @queue << [:error, e]
  end

  def close
    @closed = true

    @queue.expand(@subscribers)

    @subscribers.times do
      @queue << [:close]
    end
  end

  def closed?
    @closed
  end

  def open?
    !closed?
  end

  def dequeue
    check_channel_readable!

    type, message = @queue.dequeue
    raise ChannelClosedError, "Channel was closed" if type == :close
    raise message if type == :error # TODO: fix backtrace

    message
  end

  def each
    check_channel_readable!

    @subscribers += 1
    while message = dequeue # rubocop:disable Lint/AssignmentInCondition
      yield message
    end
  rescue ChannelClosedError
    nil
  ensure
    @subscribers -= 1
  end

  def async(parent: (@parent || Task.current), &block)
    each do |item|
      parent.async(item, &block)
    end
  end

  private

  def check_channel_writeable!
    raise ChannelClosedError, "Can't send to a closed channel" if closed?
  end

  def check_channel_readable!
    raise ChannelClosedError, "Cannot receive from a closed channel" if closed? && empty?
  end
end
