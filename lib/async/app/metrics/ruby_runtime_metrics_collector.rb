# frozen_string_literal: true

class Async::App::Metrics::RubyRuntimeMetricsCollector
  include Async::App::TimerComponent
  include Async::App::AutoloadComponent

  def on_tick = bus.publish("metrics.updated", metrics)
  def interval = 5
  def run_on_start = true
  def on_error(exception) = warn { exception }

  private

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
