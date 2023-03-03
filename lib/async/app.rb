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
    {
      bus: Async::Bus.new(app_name),
      **container_config
    }.each { container.register(_1, _2) }

    start_metrics_server!
    run!
    info { "Started" }
  rescue StandardError => e
    fatal { e }
    stop
    exit(1)
  end
  # rubocop:enable Style/GlobalVars

  def container = @container ||= Dry::Container.new
  def run! = nil
  def container_config = {}
  def app_name = :async_app

  def stop
    @task&.stop
    info { "Stopped" }
  end

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

  def force_exit!
    fatal { "Forced exit" }
    exit(1)
  end

  def start_metrics_server!
    Metrics::Server.new(prefix: app_name).tap(&:run).tap do |server|
      bus.subscribe("metrics.updated") { server.update_metrics(_1) }
    end
  end
end
