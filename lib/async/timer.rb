# frozen_string_literal: true

class Async::Timer
  attr_reader :dealay, :repeat

  class Error < StandardError; end

  class AlreadyStarted < Error; end

  def initialize(delay, repeat: true, start: true, run_on_start: false, parent: Async::Task.current, &block)
    raise ArgumentError, "Block must be given" if block.nil?

    @delay = delay
    @repeat = repeat
    @run_on_start = run_on_start
    @parent = parent
    @block = block

    self.start if start
  end

  def stop = @task.stop
  def call = @block.call

  def active? = @active

  def restart
    stop
    @task.wait
    start
  end

  def start(run: false)
    raise AlreadyStarted, "Timer already started" if active?

    @active = true

    @task = @parent.async do
      call if @run_on_start || run

      loop do
        sleep(@delay)
        call
        break unless @repeat
      rescue Async::Stop, Async::TimeoutError
        break
      ensure
        @active = false
      end
    end
  end
end
