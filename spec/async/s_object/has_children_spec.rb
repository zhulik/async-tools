# frozen_string_literal: true

RSpec.describe Async::SObject::HasChildren do
  let(:klass) do
    Class.new do
      attr_reader :parent

      include Async::SObject::HasChildren

      def initialize(parent: nil)
        @parent = parent
      end
    end
  end

  let(:object) { klass.new }

  describe "#children" do
    subject { object.children }

    it "returns a Set" do
      expect(subject).to be_a(Set)
    end
  end

  describe "#add_child" do
    subject { object.add_child(child) }

    context "when argument is a suitable object" do
      context "when has this object a parent" do
        let(:child) { double(parent: object) } # rubocop:disable RSpec/VerifiedDoubles

        it "adds a child" do
          expect { subject }.to change { object.children.count }.by(1)
        end
      end

      context "when has another object a parent" do
        let(:child) { double(parent: "something") } # rubocop:disable RSpec/VerifiedDoubles

        it "raises" do
          expect { subject }.to raise_error(described_class::MismatchParentError)
        end
      end
    end
  end

  describe "#remove_child" do
    subject { object.remove_child(child) }

    context "when child belongs to this object" do
      before { object.add_child(child) }

      let(:child) { double(parent: object) } # rubocop:disable RSpec/VerifiedDoubles

      it "removes a child" do
        expect { subject }.to change { object.children.count }.by(-1)
      end
    end

    context "when child belongs to another object" do
      let(:child) { double(parent: "someting") } # rubocop:disable RSpec/VerifiedDoubles

      it "raises" do
        expect { subject }.to raise_error(described_class::UnknownChildError)
      end
    end
  end

  describe "#free_children" do
    subject { object.free_children }

    let(:child) { double(parent: object, free: nil) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      object.add_child(child)
    end

    it "calls #free on every children" do
      subject
      expect(child).to have_received(:free)
    end
  end

  describe "#all_objects" do
    subject { object.all_objects }

    context "when there are no children" do
      it "returns a list with only self inside" do
        expect(subject).to eq([object])
      end
    end

    context "when there are children" do
      let(:object1) { klass.new(parent: object) }
      let(:object2) { klass.new(parent: object1) }

      before do
        object.add_child(object1)
        object1.add_child(object2)
      end

      it "returns a list with only self inside" do
        expect(subject).to match_array([object, object1, object2])
      end
    end
  end
end
