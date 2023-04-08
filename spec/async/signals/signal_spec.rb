# frozen_string_literal: true

RSpec.describe Async::Signals::Signal do
  let(:signal) { described_class.new(:something_changed, [String, String]) }
  let(:receiver) { double(on_something_changed: nil) } # rubocop:disable RSpec/VerifiedDoubles

  describe "#connect" do
    subject { signal.connect(callable) }

    context "when connected to an object" do
      let(:callable) { receiver }

      it "connects" do
        expect { subject }.to change { signal.connections.count }.from(0).to(1)
      end

      it "returns a Connection" do
        expect(subject).to be_an_instance_of(described_class::Connection)
      end
    end

    context "when connected to a method" do
      let(:callable) { receiver.method(:on_something_changed) }

      it "connects" do
        expect { subject }.to change { signal.connections.count }.from(0).to(1)
      end

      it "returns a Connection" do
        expect(subject).to be_an_instance_of(described_class::Connection)
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
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "#disconnect" do
    subject { signal.disconnect(callable) }

    context "when argument is an object" do
      let(:callable) { receiver }

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
      let(:callable) { receiver }

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "given callable is not connected to this signal")
      end
    end
  end

  describe "#call" do
    subject { signal.call("blah", "blah") }

    context "when has one shot connection" do
      it "notifies receiver" do
        signal.connect(receiver, one_shot: true)
        subject
        expect(receiver).to have_received(:on_something_changed)
      end

      it "removes the connection" do
        expect do
          signal.connect(receiver, one_shot: true)
          subject
        end.not_to(change { signal.connections.count })
      end
    end

    context "when connected to an object" do
      it "notifies receiver" do
        signal.connect(receiver)
        subject
        expect(receiver).to have_received(:on_something_changed)
      end
    end

    context "when connected to a signal" do
      let(:another_signal) { described_class.new(:another_signal, [String, String]) }
      let(:receiver) { double(on_another_signal: nil) } # rubocop:disable RSpec/VerifiedDoubles

      it "notifies receiver" do
        signal.connect(another_signal)
        another_signal.connect(receiver)
        subject
        expect(receiver).to have_received(:on_another_signal).with("blah", "blah")
      end
    end
  end
end
