# frozen_string_literal: true

RSpec.describe Async::Signals do
  let(:klass) do
    Class.new do
      extend Async::Signals

      signal :something_changed, String, String

      def emit_signal(*args) = emit(:something_changed, *args)
    end
  end

  let(:object) { klass.new }

  describe "emitting signals" do
    subject { object.emit_signal(*args) }

    context "when arguments are valid" do
      let(:args) { ["blah", "blah"] }

      it "notifies subscribers" do
        expect do |b|
          object.something_changed.connect(&b)
          subject
        end.to yield_control.once
      end
    end

    context "when a subclass is used as an argument" do
      let(:my_string) { Class.new(String) }
      let(:args) { ["blah", my_string.new("123")] }

      it "notifies subscribers" do
        expect do |b|
          object.something_changed.connect(&b)
          subject
        end.to yield_control.once
      end
    end

    context "when arguments have invalid types" do
      let(:args) { ["blah", 123] }

      it "raises an exception" do
        expect do
          subject
        end.to raise_error(described_class::EmitError, "expected args: [String, String]. given: [String, Integer]")
      end
    end

    context "when there are too few arguments" do
      let(:args) { ["blah"] }

      it "raises an exception" do
        expect do
          subject
        end.to raise_error(described_class::EmitError, "expected args: [String, String]. given: [String]")
      end
    end

    context "when there are too many arguments" do
      let(:args) { ["blah", "blah", "blah"] }

      it "raises an exception" do
        expect do
          subject
        end.to raise_error(described_class::EmitError,
                           "expected args: [String, String]. given: [String, String, String]")
      end
    end
  end
end
