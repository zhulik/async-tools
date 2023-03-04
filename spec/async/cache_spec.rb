# frozen_string_literal: true

RSpec.describe Async::Cache do
  let(:cache) { described_class.new }

  describe "#cache" do
    it "calls the block only when cached value is expared" do
      c = 0

      Async.map(Array.new(10)) { cache.cache("cache", duration: 1) { c += 1 } }

      expect(c).to eq(1)

      sleep(1)

      Async.map(Array.new(10)) { cache.cache("cache", duration: 1) { c += 1 } }

      expect(c).to eq(2)
    end
  end
end
