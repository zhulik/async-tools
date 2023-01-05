# frozen_string_literal: true

require "async"
require "async/http/internet"

class MetricsReporter
  def initialize(url = "http://localhost:8428/write")
    @url = url
    @internet = Async::HTTP::Internet.new
  end

  def report(name, values: {}, tags: {})
    payload = payload(name, values, tags)
    @internet.post(@url, [], [payload])
  end

  private

  def payload(name, values, tags)
    "#{name},#{serialize(tags)} #{serialize(values)}"
  end

  def serialize(value)
    value.map do |k, v|
      "#{k}=#{v}"
    end.join("\n")
  end
end
