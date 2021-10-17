# frozen_string_literal: true

module Async
  class Timer
    extend Forwardable

    attr_reader :dealay, :repeat

    class Error < StandardError; end

    class AlreadyStarted < Error; end

    def initialize(delay, repeat: true, parent: Async::Task.current, &block)
      @delay = delay
      @repeat = repeat
      @parent = parent
      @block = block

      start
    end

    def_delegator :@task, :stop, :stop
    def_delegator :@block, :call, :execute

    def active?
      @active
    end

    def restart
      stop
      @task.wait
      start
    end

    def schedule
      @parent.async do
        execute
      end
    end

    private

    def start # rubocop:disable Metrics/MethodLength
      raise AlreadyStarted, "Timer already started" if active?

      @active = true

      @task = @parent.async do
        loop do
          @parent.sleep(@delay)
          schedule
          break unless @repeat
        rescue Async::Stop, Async::TimeoutError
          break
        ensure
          @active = false
        end
      end
    end
  end
end
