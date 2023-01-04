# frozen_string_literal: true

RSpec.describe Async::Tools do
  it "has a version number" do
    expect(Async::Tools::VERSION).not_to be_nil
  end

  describe Async do
    describe ".map" do
      subject do
        described_class.map(collection, workers:) do |item|
          Async::Task.current.sleep(item)
          item * 2
        end
      end

      let(:collection) { [1, 2, 3] }

      context "when there is only one worker" do
        let(:workers) { 1 }

        it "executes jobs sequentially" do
          start = Time.now
          subject
          expect(Time.now - start).to be >= 6
        end

        it "returns results" do
          expect(subject).to eq([2, 4, 6])
        end
      end

      context "when there are multiple workers" do
        let(:workers) { 3 }

        it "executes jobs concurrently" do
          start = Time.now
          subject
          expect(Time.now - start).to be < 3.2
        end

        it "returns results" do
          expect(subject).to eq([2, 4, 6])
        end
      end
    end
  end
end
