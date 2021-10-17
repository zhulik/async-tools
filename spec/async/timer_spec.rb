# frozen_string_literal: true

RSpec.describe Async::Timer do
  describe "executiion" do
    context "when repeat is disabled" do
      it "executes the block only once" do
        n = 1
        described_class.new(0.1, repeat: false) do
          n += 1
        end
        reactor.sleep(0.3)
        expect(n).to eq(2)
      end
    end

    context "when repeat is enabled" do
      it "executes the block multiple times" do
        n = 1
        described_class.new(0.1, repeat: true) do
          n += 1
        end
        reactor.sleep(0.31)
        expect(n).to eq(4)
      end
    end
  end

  describe "#active?" do
    subject { timer.active? }

    let(:timer) { described_class.new(0.1, repeat: false) { "TEST" } }

    context "when timer is active" do
      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when timer is stopped" do
      before do
        timer.stop
      end

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#restart" do
    context "when timer is active" do
      it "restarts the timer" do
        n = 1
        timer = described_class.new(0.3, repeat: false) { n += 1 }
        reactor.sleep(0.2)
        timer.restart
        reactor.sleep(0.2)
        expect(n).to eq(1)
      end
    end

    context "when timer is not active" do
      it "restarts the timer" do
        n = 1
        timer = described_class.new(0.1, repeat: false) { n += 1 }
        reactor.sleep(0.2)
        expect(n).to eq(2)
        timer.restart
        reactor.sleep(0.2)
        expect(n).to eq(3)
      end
    end
  end
end
