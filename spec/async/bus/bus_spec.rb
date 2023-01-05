# frozen_string_literal: true

RSpec.describe Async::Bus::Bus, timeout: 500 do
  let(:bus) { described_class.new }

  it "big test" do # rubocop:disable RSpec/NoExpectationExample
    task = Async do
      bus.subscribe("test") do |_event, unsub:, meta:|
        # pp(4635 ** 12312)
        Console.logger.warn("blah") { "blah" }
      end
    end

    Async do
      loop do
        bus.publish("test")
        reactor.sleep(0.000001)
      end
    end

    task.wait
  end
end
