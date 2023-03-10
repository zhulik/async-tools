# frozen_string_literal: true

class Async::Timer
  attr_reader :dealay, :repeat

  class Error < StandardError; end

  class AlreadyStarted < Error; end

  def initialize(delay = nil, # rubocop:disable Metrics/CyclomaticComplexity,Metrics/ParameterLists
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

  def stop = @task.stop(true)
  def call = @callable.call

  def active? = @active

  def restart(delay = @delay, run: false)
    stop
    start(delay, run:)
  end

  def start(delay = @delay, run: false)
    raise AlreadyStarted, "Timer already started" if active?
    raise ArgumentError, "delay cannot be nil" if delay.nil?

    @delay = delay
    @active = true

    @task = @parent.async do
      rescued_call if @run_on_start || run

      loop do
        sleep(@delay)
        rescued_call
        break unless @repeat
      ensure
        @active = false
      end
    end
  end

  def rescued_call
    call
  rescue StandardError => e
    @on_error.call(e)
  end
end
