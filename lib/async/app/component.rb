# frozen_string_literal: true

module Async::App::Component
  def self.included(base)
    base.extend(Async::App::Injector)
    base.inject(:bus)
    base.include(Async::Logger)
  end

  def start!
    init!
    run!
  end

  def init! = nil
  def run! = nil
end
