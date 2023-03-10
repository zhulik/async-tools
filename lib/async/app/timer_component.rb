# frozen_string_literal: true

module Async::App::TimerComponent
  def init! = @timer = Async::Timer.new(run_on_start:, start: false, on_error: method(:on_error)) { tick! }

  def run!
    return if @timer.active?

    @timer.start(interval)
    info { "Started. Interval = #{interval}" }
  end

  def tick!
    debug { "Started" }
    on_tick
    debug { "Finished" }
  end

  def restart!
    @timer.restart(interval)
    info { "Restarted. Polling interval=#{interval}" }
  end

  def stop!
    @timer&.stop
    info { "Stopped" }
  end

  private

  def interval = raise NotImplementedError
  def run_on_start = raise NotImplementedError
  def on_tick = raise NotImplementedError
  def on_error(exception) = raise exception
end
