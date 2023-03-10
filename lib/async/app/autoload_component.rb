# frozen_string_literal: true

module Async::App::AutoloadComponent
  def self.included(base) = base.include(Async::App::Component)
end
