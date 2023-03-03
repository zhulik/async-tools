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

  module Component
    def self.included(base)
      base.extend(Injector)
      base.inject(:bus)

      base.include(Async::Logger)

      strict = Dry.Types::Strict

      string_like = (strict::String | strict::Symbol).constructor(&:to_s)
      kv = strict::Hash.map(string_like, strict::String)

      base.const_set(:T, Module.new do
        include Dry.Types
        const_set(:StringLike, string_like)
        const_set(:KV, kv)
      end)
    end
  end

  extend Injector
  include Async::Logger

  inject :bus

  def initialize
    raise "only one instance of #{self.class} is allowed" if $__ASYNC_APP

    $__ASYNC_APP = self

    container.register(:bus, Async::Bus.new(:__async_app))

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
