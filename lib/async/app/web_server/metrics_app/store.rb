# frozen_string_literal: true

class Async::App::WebServer::MetricsApp::Store
  include Enumerable

  def set(name, value:, suffix: "total", **labels)
    key = [name, labels]
    metrics[key] ||= { name:, labels:, suffix:, value: }
    metrics[key].merge!(value:)
  end

  def each(&) = metrics.values.each(&)

  private

  def metrics = @metrics ||= {}
end
