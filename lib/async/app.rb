# frozen_string_literal: true

class Async::App
  # rubocop:disable Style/GlobalVars

  module Injector
    def inject(name)
      define_method(name) do
        $__ASYNC_APP.container[name]
      end
      private name
    end
  end

  extend Injector
  include Async::Logger

  def initialize
    raise "only one instance if #{self.class} is allowed" if $__ASYNC_APP

    $__ASYNC_APP = self

    set_traps!
    @task = Async::Task.current
    container_config.each { container.register(_1, _2) }
    run!
    info { "Started" }
  rescue StandardError => e
    fatal { e }
    stop
    exit(1)
  end
  # rubocop:enable Style/GlobalVars

  def container = @container ||= Dry::Container.new
  def run! = nil
  def container_config = {}

  def stop
    @task&.stop
    info { "Stopped" }
  end

  private

  def set_traps!
    trap("INT") do
      force_exit! if @stopping
      @stopping = true
      warn { "Interrupted, stopping. Press ^C once more to force exit." }
      stop
    end

    trap("TERM") { stop }
  end

  def force_exit!
    fatal { "Forced exit" }
    exit(1)
  end
end
