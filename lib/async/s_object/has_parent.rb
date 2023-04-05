# frozen_string_literal: true

module Async::SObject::HasParent
  class InvalidParent < StandardError
    def initialize
      super("SObject's parent can only be an SObject or :nil for root objects")
    end
  end

  def initialize(parent: nil)
    self.parent = parent || find_parent
  end

  def parent = @parent ||= find_parent

  def parent=(parent)
    raise InvalidParent unless can_be_parent?(parent)

    @parent&.remove_child(self)

    @parent = parent
    @root = nil
    @parent&.add_child(self)
  end

  def siblings = (parent&.children || []) - [self]

  def root
    @root ||= begin
      obj = self
      obj = obj.parent until obj.parent.nil?
      obj
    end
  end

  private

  def find_parent
    binding.callers[2..].each do |caller|
      obj = caller.receiver
      return obj if can_be_parent?(obj)
    end
    nil
  end

  def can_be_parent?(obj) = (obj.is_a?(Async::SObject::HasChildren) || obj.nil?) && obj != self
end
