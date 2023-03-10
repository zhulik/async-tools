# frozen_string_literal: true

class Async::App::WebServer
  include Async::App::Component

  def initialize(apps, port: 8080)
    @router = Async::App::WebServer::Router.new(*apps)
    @endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
  end

  def run!
    Async { Async::HTTP::Server.new(@router, @endpoint).run }
    info { "Started on #{@endpoint.url}" }
  end
end
