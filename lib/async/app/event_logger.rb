# frozen_string_literal: true

class Async::App::EventLogger
  include Async::App::Component

  def after_init
    bus.subscribe(/.*/) do |payload, name|
      debug { "Event #{name} received. Payload:\n\n#{payload.pretty_inspect}\n" }
    end
  end
end
