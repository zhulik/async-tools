# frozen_string_literal: true

class Async::App::WebServer
  include Async::App::Component

  APP_ADDED = "async-app.web_app.added"

  class Router
    def initialize
      @apps = []
    end

    def add(app) = @apps << app

    def call(request)
      @apps.reverse_each { return Protocol::HTTP::Response[*_1.call(request)] if _1.can_handle?(request) }

      Protocol::HTTP::Response[404, {}, ["Not found"]]
    end
  end

  def initialize(port: 8080)
    @router = Router.new
    @endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
  end

  def after_init = bus.subscribe(APP_ADDED) { add_app(_1) }

  def add_app(app) = @router.add(app)

  def run!
    Async { Async::HTTP::Server.new(@router, @endpoint).run }
    info { "Started on #{@endpoint.url}" }
  end
end
