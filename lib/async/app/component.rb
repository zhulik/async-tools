# frozen_string_literal: true

module Async::App::Component
  def self.included(base)
    base.extend(Async::App::Injector)
    base.inject(:bus)
    base.include(Async::Logger)
  end

  def start!
    init!
    after_init
    run!
    after_run
  end

  def init! = nil
  def run! = info { "Started" }

  # TODO: unsubscribe from everything on stop
  def stop! = info { "Stopped" }

  def after_init = nil
  def after_run = nil
end
