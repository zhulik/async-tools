# frozen_string_literal: true

RSpec.describe Async::Bus::Bus, timeout: 500 do
  let(:bus) { described_class.new }

  it "big test" do # rubocop:disable RSpec/NoExpectationExample
    counter = 0

    Async do
      bus.subscribe(:test) do |_event, unsub:, meta:|
        counter += 1
      end
    end

    prev_counter = 0
    prev_time = Async::Clock.now

    Async::Timer.new(1) do
      elapsed = Async::Clock.now - prev_time
      d = counter - prev_counter

      Console.logger.warn("blah") { (d.to_f / elapsed).round }

      prev_time = Async::Clock.now
      prev_counter = counter
    end

    loop do
      bus.publish(:test)
    end
  end
end
