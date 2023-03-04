# frozen_string_literal: true

class Async::Cache
  # TODO: automatic cleanup?
  def cache(id, duration:, &)
    existing = storage[id]

    existing[:task]&.wait
    return existing[:value] if existing[:value] && Time.now - existing[:created_at] < duration

    Async do |task|
      existing[:task] = task
      task.yield

      existing.merge!(value: yield(id), created_at: Time.now)
    end
    cache(id, duration:, &)
  end

  private

  def storage = @storage ||= Hash.new { _1[_2] = {} }
end
