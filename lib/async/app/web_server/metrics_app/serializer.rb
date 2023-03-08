# frozen_string_literal: true

class Async::App::WebServer::MetricsApp::Serializer
  def initialize(prefix:, store:)
    @prefix = prefix
    @store = store
  end

  def serialize
    @store.flat_map { metric_line(_1) }
          .compact
          .join("\n")
          .then { "#{_1}\n" }
  end

  def metric_name(value) = "#{@prefix}_#{value[:name]}_#{value[:suffix]}"

  def metric_labels(value) = value[:labels].map { |tag, tag_value| "#{tag}=#{tag_value.to_s.inspect}" }.join(",")

  def metric_line(value)
    "#{metric_name(value)}{#{metric_labels(value)}} #{value[:value]}" if value.key?(:value)
  end
end
