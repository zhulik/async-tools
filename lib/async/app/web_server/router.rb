# frozen_string_literal: true

class Async::App::WebServer::Router
  extend Async::App::Injector

  inject :bus

  def initialize(metrics_prefix:)
    @metrics_prefix = metrics_prefix

    bus.subscribe("metrics.updated") { update_metrics(_1) }
    bus.subscribe("health.updated") { update_health(_1) }

    @healthy = false

    Async::App::Metrics::RubyRuntimeMonitor.new.run { update_metrics(_1) }
  end

  def call(request)
    routes.each { return _2.call(request) if _1.include?(request.path) }

    Protocol::HTTP::Response[404, {}, ["Not found"]]
  end

  private

  def update_health(state) = @healthy = state
  def update_metrics(metrics) = metrics.each { metrics_store.set(_1, **_2) }

  def metrics_store = @metrics_store ||= Async::App::Metrics::Store.new
  def serializer = @serializer ||= Async::App::Metrics::Serializer.new(prefix: @metrics_prefix)

  def render_metrics(_) = Protocol::HTTP::Response[200, {}, serializer.serialize(metrics_store)]
  def render_health(_) = Protocol::HTTP::Response[@healthy ? 200 : 500, {}]

  def routes
    @routes ||= {
      ["/metrics", "/metrics/"].freeze => ->(req) { render_metrics(req) },
      ["/health", "/health/"].freeze => ->(req) { render_health(req) }
    }.freeze
  end
end
