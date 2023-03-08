# frozen_string_literal: true

class Async::App::Metrics::RubyRuntimeMetricsCollector
  include Async::App::Component

  INTERVAL = 5

  def run
    Async::Timer.new(INTERVAL, run_on_start: true, on_error: ->(e) { warn(e) }) do
      bus.publish("metrics.updated", metrics)
    end
    info { "Started" }
  end

  def metrics
    fibers = ObjectSpace.each_object(Fiber)
    threads = ObjectSpace.each_object(Thread)
    ractors = ObjectSpace.each_object(Ractor)
    {
      ruby_fibers: { value: fibers.count },
      ruby_fibers_active: { value: fibers.count(&:alive?) },
      ruby_threads: { value: threads.count },
      ruby_threads_active: { value: threads.count(&:alive?) },
      ruby_ractors: { value: ractors.count },
      ruby_memory: { value: GetProcessMem.new.bytes.to_s("F"), suffix: "bytes" }
    }
  end
end
