# frozen_string_literal: true

class Async::App::WebApps::HealthApp
  include Async::App::WebComponent

  PATHS = ["/health", "/health/"].freeze

  def after_init
    @healthy = false
    bus.subscribe("health.updated") { @healthy = _1 }
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(_) = [@healthy ? 200 : 500]
end
