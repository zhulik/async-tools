# frozen_string_literal: true

class Async::App::WebServer::MetricsApp
  extend Async::App::Injector

  PATHS = ["/metrics", "/metrics/"].freeze

  inject :bus

  def initialize(metrics_prefix:)
    @metrics_store = Store.new
    @serializer = Serializer.new(prefix: metrics_prefix)

    bus.subscribe("metrics.updated") { update_metrics(_1) }
  end

  def can_handle?(request) = PATHS.include?(request.path)
  def call(*) = [200, {}, @serializer.serialize(@metrics_store)]

  private

  def update_metrics(metrics) = metrics.each { @metrics_store.set(_1, **_2) }
end
