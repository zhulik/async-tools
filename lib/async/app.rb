# frozen_string_literal: true

class Async::App
  extend Async::App::Injector

  include Async::Logger

  inject :bus

  # rubocop:disable Style/GlobalVars
  def initialize # rubocop:disable Metrics/MethodLength
    raise "only one instance of #{self.class} is allowed" if $__ASYNC_APP

    $__ASYNC_APP = self
    @task = Async::Task.current
    set_traps!
    init_container!

    start_event_logger!
    start_web_server!
    start_web_apps!

    start_runtime_metrics_collector!

    run!

    info { "Started" }
    bus.publish("health.updated", true)
  rescue StandardError => e
    fatal { e }
    stop
    exit(1)
  end

  def container = @container ||= Dry::Container.new
  def container_config = {}
  def async_app_name = :async_app

  def stop
    @task&.stop
    $__ASYNC_APP = nil
    info { "Stopped" }
  end

  # rubocop:enable Style/GlobalVars

  private

  def set_traps!
    trap("INT") do
      force_exit! if @stopping
      @stopping = true
      warn { "Interrupted, stopping. Press ^C once more to force exit." }
      stop
    end

    trap("TERM") { stop }
  end

  def init_container!
    container.register(:bus, Async::Bus.new)
    container.register(:async_app_name, async_app_name)

    container_config.each { container.register(_1, _2) }
  end

  def force_exit!
    fatal { "Forced exit" }
    exit(1)
  end

  def start_web_server! = WebServer.new.start!
  def start_event_logger! = EventLogger.new.start!
  def start_runtime_metrics_collector! = Async::App::Metrics::RubyRuntimeMetricsCollector.new.start!

  def start_web_apps!
    WebApps::MetricsApp.new.start!
    WebApps::HealthApp.new.start!
  end
end
