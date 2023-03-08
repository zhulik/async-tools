# frozen_string_literal: true

class Async::App::WebServer::Router
  extend Async::App::Injector

  def initialize(metrics_prefix:)
    @apps = [
      Async::App::WebServer::MetricsApp.new(metrics_prefix:),
      Async::App::WebServer::HealthApp.new
    ]
  end

  def call(request)
    @apps.each { return Protocol::HTTP::Response[*_1.call(request)] if _1.can_handle?(request) }

    Protocol::HTTP::Response[404, {}, ["Not found"]]
  end
end
