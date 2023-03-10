# frozen_string_literal: true

class Async::App::WebApps::MetricsApp
  include Async::App::WebComponent

  PATHS = ["/metrics", "/metrics/"].freeze

  inject :async_app_name

  def after_init
    store = Store.new
    @serializer = Serializer.new(prefix: async_app_name, store:)

    bus.subscribe("metrics.updated") do |metrics|
      metrics.each { store.set(_1, **_2) }
    end
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(*) = [200, {}, @serializer.serialize]
end
