# frozen_string_literal: true

class Async::App::WebServer::MetricsApp
  include Async::App::Component

  PATHS = ["/metrics", "/metrics/"].freeze

  def initialize(metrics_prefix:)
    store = Store.new
    @serializer = Serializer.new(prefix: metrics_prefix, store:)

    bus.subscribe("metrics.updated") do |metrics|
      metrics.each { store.set(_1, **_2) }
    end
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(*) = [200, {}, @serializer.serialize]
end
