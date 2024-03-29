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

    context "when neither callable or block is given" do
      subject { signal.connect }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "callable OR block must be passed")
      end
    end
  end

  describe "#disconnect" do
    subject { signal.disconnect(callable) }

    context "when argument is lambda" do
      let(:callable) { ->(a, b) {} }

      before { signal.connect(callable) }

      it "unsubscribes" do
        expect { subject }.to change { signal.connections.count }.from(1).to(0)
      end
    end

    context "when argument is a signal" do
      let(:callable) { described_class.new(:another_signal, [String, String]) }

      before { signal.connect(callable) }

      it "unsubscribes" do
        expect { subject }.to change { signal.connections.count }.from(1).to(0)
      end
    end

    context "when argument is invalid" do
      let(:callable) { "blah" }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "given callable is not connected to this signal")
      end
    end

    context "when argument was not subscribed" do
      let(:callable) { ->(a, b) {} }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "given callable is not connected to this signal")
      end
    end
  end

  describe "#emit" do
    subject { signal.send(:emit, "blah", "blah") }

    context "when connected to a block" do
      it "notifies receiver" do
        expect do |b|
          signal.connect(&b)
          subject
        end.to yield_control.once
      end
    end

    context "when has one shot connection" do
      it "notifies receiver" do
        expect do |b|
          signal.connect(one_shot: true, &b)
          subject
        end.to yield_control.once
      end

      it "removes the connection" do
        expect do
          signal.connect(->(a, b) {}, one_shot: true)
          subject
        end.not_to(change { signal.connections.count })
      end
    end

    context "when connected to a callable" do
      it "notifies receiver" do
        expect do |b|
          signal.connect(lambda(&b)) # rubocop:disable Lint/LambdaWithoutLiteralBlock
          subject
        end.to yield_control.once
      end
    end

    context "when connected to a signal" do
      let(:another_signal) { described_class.new(:another_signal, [String, String]) }

      it "notifies receiver" do
        signal.connect(another_signal)
        expect do |b|
          another_signal.connect(&b)
          subject
        end.to yield_control.once
      end
    end
  end
end
