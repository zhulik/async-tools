# frozen_string_literal: true

class Async::App::WebServer::Router
  extend Async::App::Injector

  def initialize
    @apps = []
  end

  def add(app) = @apps << app

  def call(request)
    @apps.reverse_each { return Protocol::HTTP::Response[*_1.call(request)] if _1.can_handle?(request) }

    Protocol::HTTP::Response[404, {}, ["Not found"]]
  end
end
