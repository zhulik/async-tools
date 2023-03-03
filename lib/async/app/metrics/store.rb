# frozen_string_literal: true

class Async::App::Metrics::Store
  include Enumerable

  def set(name, value:, suffix: "total", **labels)
    key = [name, labels]
    counters[key] ||= { name:, labels:, suffix:, value: }
    counters[key].merge!(value:)
  end

  def each(&) = counters.values.each(&)

  private

  def counters = @counters ||= {}
end
