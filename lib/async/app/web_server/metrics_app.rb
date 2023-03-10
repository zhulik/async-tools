# frozen_string_literal: true

class Async::App::WebServer::MetricsApp
  include Async::App::Component

  PATHS = ["/metrics", "/metrics/"].freeze

  inject :async_app_name

  def after_init
    store = Store.new
    @serializer = Serializer.new(prefix: async_app_name, store:)

    bus.subscribe("metrics.updated") do |metrics|
      metrics.each { store.set(_1, **_2) }
    end
  end

  def after_run = bus.publish(Async::App::WebServer::APP_ADDED, self)

  def can_handle?(request) = PATHS.include?(request.path)
  def call(*) = [200, {}, @serializer.serialize]
end
