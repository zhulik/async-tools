# frozen_string_literal: true

module Async::App::TimerComponent
  def self.included(base)
    base.include(Async::App::Component)
    base.include(InstanceMethods)
  end

  module InstanceMethods
    def init!
      super
      @timer = Async::Timer.new(run_on_start:, start: false, on_error: method(:on_error)) { tick! }
    end

    def run!
      super
      return if @timer.active?

      @timer.start(interval)
      info { "Started. Interval = #{interval}" }
    end

    def stop!
      super
      @timer&.stop
      info { "Stopped" }
    end

    # TimerComponent - specific methods
    def tick!
      debug { "Started" }
      on_tick
      debug { "Finished" }
    end

    def restart!
      @timer.restart(interval)
      info { "Restarted. Polling interval=#{interval}" }
    end

    private

    def interval = raise NotImplementedError
    def run_on_start = raise NotImplementedError
    def on_tick = raise NotImplementedError
    def on_error(exception) = raise exception
  end
end
