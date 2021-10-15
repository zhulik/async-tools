# frozen_string_literal: true

RSpec.describe Async::Q do
  let(:q) { described_class.new(limit, items: items, parent: reactor) }
  let(:limit) { nil }
  let(:items) { [] }

  describe "#initialize" do
    context "when the items array is bigger than the limit" do
      it "raises an ArgumentError" do
        expect do
          described_class.new(1, items: [1, 2, 3], parent: reactor)
        end.to raise_error(ArgumentError, "Items size is greter than limit: 3 > 1")
      end
    end
  end

  describe "#resize" do
    subject { q.resize(new_limit) }

    let(:limit) { 5 }

    context "when new limit is greater than current limit" do
      let(:new_limit) { 6 }

      it "changes the limit" do
        expect { subject }.to change(q, :limit).from(5).to(6)
      end
    end

    context "when new limit is 0" do
      let(:new_limit) { 0 }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError, "Limit cannot be <= 0: 0")
      end
    end

    context "when new limit lower than the current limit" do
      context "when new limit is greater than current size" do
        let(:new_limit) { 4 }

        before do
          3.times do
            q << "item"
          end
        end

        it "changes the limit" do
          expect { subject }.to change(q, :limit).from(5).to(4)
        end
      end

      context "when new limit is lower than current size" do
        let(:new_limit) { 3 }

        before do
          4.times do
            q << "item"
          end
        end

        it "raises an Argument error" do
          expect { subject }.to raise_error(ArgumentError, "New limit cannot be lower than the current size: 4 > 3")
        end
      end
    end
  end
end
