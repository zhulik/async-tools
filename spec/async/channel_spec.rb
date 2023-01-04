# frozen_string_literal: true

RSpec.describe Async::Channel do
  let(:channel) { described_class.new(limit) }
  let(:limit) { 1 }

  describe "#initialize" do
    it "initializes with 0 subscribers" do
      expect(channel.subscribers).to eq(0)
    end

    it "initializes not closed" do
      expect(channel).not_to be_closed
    end

    it "initializes open" do
      expect(channel).to be_open
    end
  end

  describe "#enqueue" do
    context "when the channel is open" do
      it "enqueues the messages and subscribers received it" do
        reactor.async do |task|
          10.times do |i|
            task.sleep(0.001)
            channel.enqueue(i)
          end
        end

        10.times do |j|
          expect(channel.dequeue).to eq(j)
        end
      end
    end

    context "when channel is closed" do
      before { channel.close }

      it "raises an exception" do
        expect { channel.enqueue("message") }.to raise_error(described_class::ChannelClosedError)
      end
    end
  end

  describe "#close" do
    it "closes the channel" do
      expect { channel.close }.to change(channel, :closed?).from(false).to(true)
    end

    it "does not wait for all subscribers" do
      total_sum = 0
      reactor.async do
        101.times do |n|
          channel << n
        end
        channel.close
        expect(total_sum).to be < 5050
      end

      barrier = Async::Barrier.new
      5.times do
        barrier.async do |task|
          channel.each do |n|
            task.sleep(rand / 8)
            total_sum += n
          end
        end
      end
      barrier.wait
      expect(total_sum).to eq(5050)
    end
  end
end
