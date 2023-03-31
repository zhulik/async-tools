# frozen_string_literal: true

RSpec.describe Async::Signals::Signal do
  let(:signal) { described_class.new(:something_changed, [String, String]) }

  describe "#connect" do
    subject { signal.connect(callable) }

    context "when callable's arity fits" do
      let(:callable) { ->(a, b) {} }

      it "connects" do
        expect { subject }.to change { signal.connections.count }.from(0).to(1)
      end

      it "returns a Connection" do
        expect(subject).to be_an_instance_of(described_class::Connection)
      end
    end

    context "when callable's arity does not fit" do
      let(:callable) { ->(a) {} }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "callable must have arity of 2, given: 1")
      end
    end

    context "when connecting to another signal" do
      context "when signal's arity fits" do
        let(:callable) { described_class.new(:another_signal, [String, String]) }

        it "connects" do
          expect { subject }.to change { signal.connections.count }.from(0).to(1)
        end

        it "returns a Connection" do
          expect(subject).to be_an_instance_of(described_class::Connection)
        end
      end

      context "when signal's arity does not fit" do
        let(:callable) { described_class.new(:another_signal, [String]) }

        it "raises an exception" do
          expect { subject }.to raise_error(ArgumentError, "target signal must have similar type signature. Expected: [String, String]. given: [String]")
        end
      end
    end

    context "when connecting to a non-callable" do
      let(:callable) { "foo" }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "callable must respond to #call or be a Signal")
      end
    end
  end
end
