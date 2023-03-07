# frozen_string_literal: true

RSpec.describe Async::Cache do
  let(:cache) { described_class.new }

  describe "#cache" do
    it "calls the block only when cached value is expared" do
      expect do |b|
        Async.map(Array.new(10)) { cache.cache("cache", duration: 0.2, &b) }
      end.to yield_control.once

      sleep(0.1)

      expect do |b|
        Async.map(Array.new(10)) { cache.cache("cache", duration: 0.2, &b) }
      end.not_to yield_control

      sleep(0.1)

      expect do |b|
        Async.map(Array.new(10)) { cache.cache("cache", duration: 1, &b) }
      end.to yield_control.once
    end
  end

  describe "#cleanup!" do
    it "cleans up stale records" do
      cache.cache("cache", duration: 0.2)

      cache.cleanup!
      expect(cache.count).to eq(1)
      sleep(0.2)
      cache.cleanup!
      expect(cache.count).to eq(0)
    end
  end
end
