# frozen_string_literal: true

RSpec.describe Async::Throttler do
  let(:throttler) { described_class.new(1, 20) }

  describe "#wait" do
    it "throttles requests" do
      start = Time.now
      10.times { throttler.wait }
      expect(Time.now - start).to be_within(0.01).of(0.5)
    end
  end
end
