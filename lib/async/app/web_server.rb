# frozen_string_literal: true

class Async::App::WebServer
  include Async::App::Component

  APP_ADDED = "async-app.web_app.added"

  def initialize(port: 8080)
    @router = Async::App::WebServer::Router.new
    @endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
  end

  def after_init = bus.subscribe(APP_ADDED) { add_app(_1) }

  def add_app(app) = @router.add(app)

  def run!
    Async { Async::HTTP::Server.new(@router, @endpoint).run }
    info { "Started on #{@endpoint.url}" }
  end
end
