# frozen_string_literal: true

RSpec.describe Async::Bus::Bus do
  let(:bus) { described_class.new }

  it "big test" do # rubocop:disable RSpec/NoExpectationExample
    task = Async do
      bus.subscribe("test") do |event, unsub:, meta:| # rubocop:disable Lint/UnusedBlockArgument
        pp("Receive: event=#{event}")
        unsub.call
      end
    end

    Async do
      loop do
        # pp("Publish")
        bus.publish("test")
        # reactor.sleep(0.01)
      end
    end

    task.wait
  end
end
