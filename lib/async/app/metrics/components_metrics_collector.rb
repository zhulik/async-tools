# frozen_string_literal: true

class Async::App::Metrics::ComponentsMetricsCollector
  include Async::App::TimerComponent
  include Async::App::AutoloadComponent

  def on_tick = bus.publish("metrics.updated", metrics)
  def interval = 5
  def run_on_start = true
  def on_error(exception) = warn { exception }

  private

  def metrics
    {
      async_app_components: { value: Async::App.instance.components.count },
      async_app_autoloadable_components: { value: Async::App.instance.autoloadable_components.count },
      async_app_timer_components: { value: Async::App.instance.timer_components.count }
    }
  end
end
