# frozen_string_literal: true

class Async::App::Metrics::Server
  include Async::Logger

  PATHS = ["/metrics", "/metrics/"].freeze

  def initialize(prefix:, port: 8080)
    @prefix = prefix
    @port = port
  end

  def run
    Async::App::Metrics::RubyRuntimeMonitor.new.run { update_metrics(_1) }

    endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{@port}")
    Async { Async::HTTP::Server.new(self, endpoint).run }
    info { "Started on #{endpoint.url}" }
  end

  def call(request)
    return Protocol::HTTP::Response[404, {}, ["Not found"]] unless PATHS.include?(request.path)

    Protocol::HTTP::Response[200, {}, serializer.serialize(metrics_store)]
  end

  def update_metrics(metrics) = metrics.each { metrics_store.set(_1, **_2) }

  private

  def metrics_store = @metrics_store ||= Async::App::Metrics::Store.new
  def serializer = @serializer ||= Async::App::Metrics::Serializer.new(prefix: @prefix)
end
