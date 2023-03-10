# frozen_string_literal: true

class Async::App::WebServer::HealthApp
  include Async::App::Component

  PATHS = ["/health", "/health/"].freeze

  def after_init
    @healthy = false
    bus.subscribe("health.updated") { @healthy = _1 }
  end

  def after_run = bus.publish(Async::App::WebServer::APP_ADDED, self)

  def can_handle?(request) = PATHS.include?(request.path)
  def call(_) = [@healthy ? 200 : 500]
end
