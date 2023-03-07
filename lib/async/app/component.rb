# frozen_string_literal: true

module Async::App::Component
  def self.included(base)
    base.extend(Async::App::Injector)
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

  def run = nil
end
