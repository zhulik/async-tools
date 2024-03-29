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

  describe "#call" do
    subject { pool.call(task) }

    let(:task) { 1 }

    it "returns a Async::ResultNotification" do
      expect(subject).to be_an_instance_of(Async::ResultNotification)
      expect(subject.wait).to eq(2)
    end
  end

  describe "watiting" do
    context "when no workers are busy" do
      it "returns 0" do
        expect(subject.waiting).to eq(0)
      end
    end
  end

  it "stress 1", timeout: 120 do
    pool = described_class.new(workers: 10) do |arg|
      sleep(0.1)
      arg * 2
    end

    barrier = Async::Barrier.new

    (1..30).each do |i|
      barrier.async do
        expect(pool.call(i).wait).to eq(i * 2)
      end
    end

    barrier.wait
    pool.stop
    pool.wait
  end

  it "stress 2", timeout: 120 do
    pool = described_class.new(workers: 10) do |arg|
      sleep(0.2)
      arg * 2
    end

    barrier = Async::Barrier.new

    (1..30).each do |i|
      barrier.async do
        expect(pool.call(i).wait).to eq(i * 2)
      end
    end

    sleep(0.1)

    barrier.stop
    barrier.wait

    pool.stop
    pool.wait
  end

  it "stress 3" do # rubocop:disable RSpec/NoExpectationExample
    pool = described_class.new(workers: 500) do |arg|
      sleep(rand(10).to_f / 10)
      arg * 2
    end

    barrier = Async::Barrier.new

    100.times do
      barrier.async do
        loop do
          pool.call(1).wait
          sleep(0.1)
        end
      rescue described_class::StoppedError
        # It's ok
      end
    end

    sleep(0.1)

    pool.stop
    pool.wait

    sleep(0.1)

    barrier.stop
    barrier.wait
  end

  it "stress 4" do
    pool = described_class.new(workers: 5) do |_arg|
      raise StandardError
    end

    100.times do
      expect { pool.call(1).wait }.to raise_error(StandardError)
    end

    pool.stop
    pool.wait
  end
end
