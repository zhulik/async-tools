# frozen_string_literal: true

RSpec.describe Async::Bus::Bus, timeout: 500 do
  let(:bus) { described_class.new }
  let(:pool) do
    Async::WorkerPool.new(workers: 10) do |event|
      reactor.sleep(1)
      pp("Receive: event=#{event}")
    end
  end

  xit "big test" do # rubocop:disable RSpec/PendingWithoutReason
    task = Async do
      bus.subscribe("test", pool)
    end

    Async do
      loop do
        # pp("Publish")
        bus.publish("test")
        reactor.sleep(0.1)
      end
    end

    task.wait
  end
end
