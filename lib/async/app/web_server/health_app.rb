# frozen_string_literal: true

class Async::App::WebServer::HealthApp
  extend Async::App::Injector

  inject :bus

  PATHS = ["/health", "/health/"].freeze

  def initialize
    @healthy = false

    bus.subscribe("health.updated") { @healthy = _1 }
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(_) = [@healthy ? 200 : 500]
end
