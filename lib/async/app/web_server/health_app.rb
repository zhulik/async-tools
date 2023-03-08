# frozen_string_literal: true

class Async::App::WebServer::HealthApp
  include Async::App::Component

  PATHS = ["/health", "/health/"].freeze

  def initialize
    @healthy = false

    bus.subscribe("health.updated") { @healthy = _1 }
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(_) = [@healthy ? 200 : 500]
end
