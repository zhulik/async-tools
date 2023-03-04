# frozen_string_literal: true

class Async::Cache
  Item = Struct.new("Item", :task, :value, :created_at, :duration) do
    def expired? = created_at && Time.now - created_at >= duration
  end

  def cache(id, duration:, parent: Async::Task.current)
    cleanup!
    find_or_create(id, duration:) do |item|
      parent.async do |task|
        item.task = task
        item.value = yield(id) if block_given?
        item.created_at = Time.now
      end.wait
    end.value
  end

  def cleanup! = storage.delete_if { _2.expired? }
  def count = storage.count

  private

  def find_or_create(id, duration:)
    storage[id].tap do |item|
      item.duration = duration
      item.task&.wait
      return item if item.created_at

      yield(item)
    end
  end

  def storage = @storage ||= Hash.new { _1[_2] = Item.new }
end
