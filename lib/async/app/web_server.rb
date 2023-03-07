# frozen_string_literal: true

class Async::App::WebServer
  extend Async::App::Injector

  include Async::Logger

  inject :bus

  def initialize(metrics_prefix:, port: 8080)
    @router = Async::App::WebServer::Router.new(metrics_prefix:)
    @port = port
  end

  def run
    endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{@port}")
    Async { Async::HTTP::Server.new(@router, endpoint).run }
    info { "Started on #{endpoint.url}" }
  end

  def call(request) = @router.call(request)
end
