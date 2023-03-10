# frozen_string_literal: true

module Async::App::WebComponent
  def self.included(base)
    base.include(Async::App::Component)
    base.include(InstanceMethods)
  end

  module InstanceMethods
    def run! = bus.publish(Async::App::WebServer::APP_ADDED, self)

    def can_handle?(request) = raise NotImplementedError
    def call(*) = raise NotImplementedError
  end
end
