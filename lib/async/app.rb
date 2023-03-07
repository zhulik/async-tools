# frozen_string_literal: true

class Async::App
  extend Async::App::Injector

  include Async::Logger

  inject :bus

  # rubocop:disable Style/GlobalVars
  def initialize
    raise "only one instance of #{self.class} is allowed" if $__ASYNC_APP

    $__ASYNC_APP = self
    @task = Async::Task.current

    set_traps!
    init_container!

    start_event_logger!
    start_metrics_server!
    run!
    info { "Started" }
  rescue StandardError => e
    fatal { e }
    stop
    exit(1)
  end

  def container = @container ||= Dry::Container.new
  def run! = nil
  def container_config = {}
  def app_name = :async_app

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
    {
      bus: Async::Bus.new,
      **container_config
    }.each { container.register(_1, _2) }
  end

  def force_exit!
    fatal { "Forced exit" }
    exit(1)
  end

  def start_metrics_server!
    Metrics::Server.new(prefix: app_name).tap(&:run).tap do |server|
      bus.subscribe("metrics.updated") { server.update_metrics(_1) }
    end
  end

  def start_event_logger! = EventLogger.new.run
end
