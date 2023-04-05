# frozen_string_literal: true

class Async::SObject
  include HasParent
  include HasChildren

  class FreedObjectAccess < StandardError; end

  def self.s_methods = instance_methods - Object.instance_methods
  def free_children = children.dup.each(&:free)
  def freed? = @freed || false

  def free
    raise FreedObjectAccess if @freed

    @freed = true

    free_children

    self.parent = nil
  end
end
