# frozen_string_literal: true

require "binding_of_caller"

RSpec.describe Async::SObject::HasParent do
  let(:klass) do
    Class.new do
      include Async::SObject::HasParent
    end
  end

  let(:object) { klass.new }

  let(:parent_class) do
    Class.new do
      include Async::SObject::HasParent
      include Async::SObject::HasChildren

      def create_child = self.class::K.new
    end.tap { _1.const_set(:K, klass) } # rubocop:disable Style/MultilineBlockChain
  end

  describe "#parent" do
    subject { object.parent }

    context "when created a root object" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when created as a child" do
      let(:parent) { parent_class.new }
      let(:object) { parent.create_child }

      it "returns parent" do
        expect(subject).to eq(parent)
      end
    end
  end

  describe "#parent=" do
    subject { object.parent = parent }

    context "when object does not have a parent yet" do
      context "when argument is valid parent" do
        let(:parent) { parent_class.new }

        it "assigns parent" do
          expect { subject }.to change(object, :parent).from(nil).to(parent)
        end
      end

      context "when argument is an invalid parent" do
        let(:parent) { "something" }

        it "raises" do
          expect { subject }.to raise_error(described_class::InvalidParent)
        end
      end

      context "when argument is nil" do
        let(:parent) { nil }

        it "does not change the parent" do
          expect { subject }.not_to change(object, :parent)
        end
      end
    end

    context "when object has a parent already" do
      before do
        object.parent = old_parent
      end

      let(:old_parent) { parent_class.new }

      context "when argument is an invalid parent" do
        let(:parent) { "something" }

        it "raises" do
          expect { subject }.to raise_error(described_class::InvalidParent)
        end

        it "does not change parent" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(object, :parent)
        end

        it "does not change parent's children" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(old_parent, :children)
        end
      end

      context "when argument is nil" do
        let(:parent) { nil }

        it "removes parent" do
          expect { subject }.to change(object, :parent).from(old_parent).to(nil)
        end
      end

      context "when argument is current parent" do
        let(:parent) { old_parent }

        it "does not change parent" do
          expect { subject }.not_to change(object, :parent)
        end

        it "does not change parent's children" do
          expect { subject }.not_to change(old_parent, :children)
        end
      end

      context "when argument is self" do
        let(:parent) { object }

        it "raises" do
          expect { subject }.to raise_error(described_class::InvalidParent)
        end

        it "does not change parent" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(object, :parent)
        end

        it "does not change parent's children" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(old_parent, :children)
        end
      end
    end
  end

  describe "#siblings" do
    subject { object.siblings }

    context "when there are no siblings" do
      it "returns an empty array" do
        expect(subject).to be_empty
      end
    end

    context "when there are siblings" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:parent) { parent_class.new }
      let(:object) { parent.create_child }
      let!(:object1) { parent.create_child }
      let!(:object2) { parent.create_child }

      it "returns a set of siblings" do
        expect(subject).to eq(Set.new([object1, object2]))
      end
    end
  end

  describe "#root" do
    subject { object.root }

    context "when object is root itself" do
      it "returns self" do
        expect(subject).to eq(object)
      end
    end

    context "when root is another object" do
      let(:parent) { parent_class.new }
      let(:object) { parent.create_child }

      it "returns a set of siblings" do
        expect(subject).to eq(parent)
      end
    end
  end
end
