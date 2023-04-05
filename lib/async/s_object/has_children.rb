# frozen_string_literal: true

module Async::SObject::HasChildren
  class MismatchParentError < StandardError; end
  class UnknownChildError < StandardError; end

  def children = @children ||= Set.new

  def add_child(obj)
    return children << obj if obj.parent == self

    raise MismatchParentError
  end

  def remove_child(obj)
    raise UnknownChildError unless children.include?(obj)

    children.delete(obj)
  end

  def free_children = children.each(&:free)
  def all_objects = children.flat_map(&:all_objects) + [self]
end
