# frozen_string_literal: true

class Async::App::WebServer::Router
  extend Async::App::Injector

  def initialize(*apps)
    @apps = apps
  end

  def call(request)
    @apps.each { return Protocol::HTTP::Response[*_1.call(request)] if _1.can_handle?(request) }

    Protocol::HTTP::Response[404, {}, ["Not found"]]
  end
end
