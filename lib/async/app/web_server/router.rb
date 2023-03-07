# frozen_string_literal: true

class Async::App::WebServer::Router
  extend Async::App::Injector

  inject :bus

  PATHS = ["/metrics", "/metrics/"].freeze

  def initialize(metrics_prefix:)
    @metrics_prefix = metrics_prefix

    bus.subscribe("metrics.updated") { update_metrics(_1) }
    Async::App::Metrics::RubyRuntimeMonitor.new.run { update_metrics(_1) }
  end

  def call(request)
    return Protocol::HTTP::Response[404, {}, ["Not found"]] unless PATHS.include?(request.path)

    Protocol::HTTP::Response[200, {}, serializer.serialize(metrics_store)]
  end

  def update_metrics(metrics) = metrics.each { metrics_store.set(_1, **_2) }

  private

  def metrics_store = @metrics_store ||= Async::App::Metrics::Store.new
  def serializer = @serializer ||= Async::App::Metrics::Serializer.new(prefix: @metrics_prefix)
end
