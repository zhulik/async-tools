# frozen_string_literal: true

require_relative "tools/version"

require "async"
require "async/notification"
require "async/semaphore"

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.tag = File.basename(__FILE__, ".rb")
loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
loader.push_dir(File.expand_path("..", __dir__.to_s))
loader.setup

module Async
  module Tools
    class Error < StandardError; end
    # Your code goes here...
  end

  def self.map(collection, **params, &)
    WorkerPool.with(queue_limit: collection.count, **params) do |pool|
      pool.schedule_all(collection, &).map(&:wait)
    end
  end
end
