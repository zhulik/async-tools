# frozen_string_literal: true

module Async
  class WorkerPool
    extend Forwardable

    class Error < StandardError; end

    class StoppedError < Error; end

    class << self
      def start(...)
        new(...)
      end

      def with(*args, **params, &)
        new(*args, **params).with(&)
      end
    end

    def initialize(workers: 1, queue_limit: 1, parent: Async::Task.current, &block)
      @queue_limit = queue_limit
      @parent = parent
      @block = block

      @semaphore = Async::Semaphore.new(workers, parent: @parent)
      @channel = Async::Channel.new(@queue_limit, parent: @semaphore)
      @task = start
    end

    def_delegator :@semaphore, :limit, :workers
    def_delegator :@semaphore, :count, :busy

    def_delegator :@task, :wait

    def_delegator :@channel, :close, :stop
    def_delegator :@channel, :open?, :running?
    def_delegator :@channel, :closed?, :stopped?

    def waiting
      @semaphore.waiting.size
    end

    def schedule(task, &block)
      block ||= @block
      raise ArgumentError, "Block must be passed to #schedule if it's not passed to #initlaize" if block.nil?

      raise StoppedError, "The pool was stopped" unless running?

      ResultNotification.new.tap do |notification|
        @channel.enqueue([notification, task, block])
      end
    end

    def schedule_all(tasks, &block)
      block ||= @block

      raise ArgumentError, "Block must be passed to #schedule_all if it's not passed to #initlaize" if block.nil?

      raise StoppedError, "The pool was stopped" unless running?

      tasks = tasks.map { |task| [ResultNotification.new, task, block] }

      @channel.enqueue_all(tasks)
      tasks.map(&:first)
    end

    def with
      yield self
    ensure
      stop
      wait
    end

    private

    def start
      @parent.async do
        @channel.async do |_, (notification, task, block)|
          notification.signal do
            block.call(task)
          end
        end
      end
    end
  end
end
