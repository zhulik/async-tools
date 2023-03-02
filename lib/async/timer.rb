# frozen_string_literal: true

class Async::Timer
  attr_reader :dealay, :repeat

  class Error < StandardError; end

  class AlreadyStarted < Error; end

  def initialize(delay, # rubocop:disable Metrics/CyclomaticComplexity,Metrics/ParameterLists
                 repeat: true,
                 start: true,
                 run_on_start: false,
                 call: nil,
                 on_error: nil,
                 parent: Async::Task.current, &block)
    callables = [call, block]
    raise ArgumentError, "either block or call: must be given" if callables.all?(&:nil?) || callables.none?(&:nil?)

    @delay = delay
    @repeat = repeat
    @run_on_start = run_on_start
    @callable = call || block
    @on_error = on_error || ->(e) { raise e }
    @parent = parent

    self.start if start
  end

  def stop = @task.stop
  def call = @callable.call

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
      rescue StandardError => e
        @on_error.call(e)
      ensure
        @active = false
      end
    end
  end
end
