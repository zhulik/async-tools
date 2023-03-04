# frozen_string_literal: true

class Async::Cache
  Item = Struct.new("Item", :task, :value, :created_at, :duration, :resolved) do
    def expired? = resolved && Time.now - created_at >= duration
  end

  def cache(id, duration:)
    fetch(id, duration:).tap do |item|
      return item.value if item.resolved

      Async do |task|
        item.task = task
        item.created_at = Time.now

        item.value = yield(id) if block_given?
        item.resolved = true
      end.wait
    end.value
  end

  def cleanup! = storage.delete_if { _2.expired? }
  def count = storage.count

  private

  def fetch(id, duration:)
    cleanup!
    storage[id].tap do |item|
      item.duration = duration
      item.task&.wait
    end
  end

  def storage = @storage ||= Hash.new { _1[_2] = Item.new }
end
