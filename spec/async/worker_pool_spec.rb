# frozen_string_literal: true

RSpec.describe Async::WorkerPool do
  let(:pool) { described_class.new { |arg| arg * 2 } }

  after do
    pool.stop
    pool.wait
  end

  describe ".start" do
    subject { described_class.start { nil } }

    it "returns an instance of Pool" do
      expect(subject).to be_an_instance_of(described_class)
    end

    it "returns a running Pool" do
      expect(subject).to be_running
    end
  end

  describe "#schedule" do
    subject { pool.schedule(task) }

    let(:task) { 1 }

    it "returns a Async::ResultNotification" do
      expect(subject).to be_an_instance_of(Async::ResultNotification)
      expect(subject.wait).to eq(2)
    end
  end

  it "stress 1", timeout: 120 do
    pool = described_class.new(workers: 10) do |arg|
      Async::Task.current.sleep(0.2)
      arg * 2
    end

    barrier = Async::Barrier.new

    (1..30).each do |i|
      barrier.async do
        expect(pool.schedule(i).wait).to eq(i * 2)
      end
    end

    barrier.wait
    pool.stop
    pool.wait
  end

  it "stress 2", timeout: 120 do
    pool = described_class.new(workers: 10) do |arg|
      Async::Task.current.sleep(0.2)
      arg * 2
    end

    barrier = Async::Barrier.new

    (1..30).each do |i|
      barrier.async do
        expect(pool.schedule(i).wait).to eq(i * 2)
      end
    end

    reactor.sleep(2)

    barrier.stop
    barrier.wait

    pool.stop
    pool.wait
  end

  it "stress 3" do
    pool = described_class.new(workers: 500) do |arg|
      Async::Task.current.sleep(rand(10).to_f / 10)
      arg * 2
    end

    barrier = Async::Barrier.new

    100.times do
      barrier.async do
        loop do
          pool.schedule(1).wait
          Async::Task.current.sleep(1)
        end
      rescue described_class::StoppedError
        # It's ok
      end
    end

    reactor.sleep(3)

    pool.stop
    pool.wait

    reactor.sleep(3)

    barrier.stop
    barrier.wait
  end

  it "stress 4" do
    pool = described_class.new(workers: 5) do |_arg|
      raise StandardError
    end

    100.times do
      expect { pool.schedule(1).wait }.to raise_error(StandardError)
    end

    pool.stop
    pool.wait
  end
end
