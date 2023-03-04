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
  # Your code goes here...
  module Tools # rubocop:disable Style/ClassAndModuleChildren
    class Error < StandardError
    end
  end

  def self.map(collection, concurrency: nil, parent: Async::Task.current, &)
    Async::Semaphore.new(concurrency || collection.count, parent:).then do |s|
      collection.map do |item|
        s.async { yield(item) }
      end.map(&:wait)
    end
  end
end
