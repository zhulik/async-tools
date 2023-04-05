# frozen_string_literal: true

require "binding_of_caller"

RSpec.describe Async::SObject do
  let(:object) { described_class.new }

  describe "#free_children" do
    subject { object.free_children }

    let(:child) { described_class.new(parent: object) }

    before do
      object.add_child(child)
    end

    it "frees all children" do
      expect { subject }.to change(child, :freed?).to(true)
    end

    it "removes all children" do
      expect { subject }.to change { object.children.count }.to(0)
    end
  end
end
