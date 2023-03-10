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
    start_web_server!

    autoload_components!
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

  def autoload_components!
    ObjectSpace.each_object(Class)
               .select { _1.included_modules.include?(Async::App::AutoloadComponent) }
               .each { _1.new.start! }
  end

  def start_web_server! = WebServer.new.start!
  def start_event_logger! = EventLogger.new.start!
end
