# frozen_string_literal: true

class Async::WorkerPool
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

  def workers = @semaphore.limit
  def busy = @semaphore.count
  def stop = @channel.close
  def waiting = @semaphore.waiting.size
  def wait = @task.wait

  def stopped? = !running?
  def running? = @channel.open?

  def call(*args, **params, &block)
    block ||= @block
    raise ArgumentError, "Block must be passed to #schedule if it's not passed to #initlaize" if block.nil?

    raise StoppedError, "The pool was stopped" unless running?

    Async::ResultNotification.new.tap do |notification|
      @channel.enqueue([notification, [args, params], block])
    end
  end

  def schedule_all(tasks, &block)
    block ||= @block

    raise ArgumentError, "Block must be passed to #schedule_all if it's not passed to #initlaize" if block.nil?

    raise StoppedError, "The pool was stopped" unless running?

    tasks = tasks.map { |task| [Async::ResultNotification.new, [[task], {}], block] }

    @channel.enqueue_all(tasks)
    tasks.map(&:first)
  end

  def with
    yield(self)
  ensure
    stop
    wait
  end

  private

  def start
    @parent.async do
      @channel.async do |_, (notification, (args, params), block)|
        notification.signal do
          block.call(*args, **params)
        end
      end
    end
  end
end
