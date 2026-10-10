require "spec_helper"

RSpec.describe ContainerTester do
  subject(:tester) { described_class.new(compose_file: "multi_process/stand-alone.yml") }

  let(:compose) { instance_double(Compose) }
  let(:success) { Net::HTTPOK.new("1.1", "200", "OK") }
  let(:unavailable) { Net::HTTPServiceUnavailable.new("1.1", "503", "Unavailable") }

  before do
    allow(Compose).to receive(:new).and_return(compose)
    allow(compose).to receive(:run).with("up", "--detach", "--pull", anything, "--quiet-pull")
    allow(compose).to receive(:run).with("port", "huginn", "3000").and_return("127.0.0.1:12345\n")
    allow(tester).to receive(:sleep)
  end

  it "waits for HTTP success rather than accepting an error response" do
    expect(Net::HTTP).to receive(:start).ordered.and_return(unavailable)
    expect(Net::HTTP).to receive(:start).ordered.and_return(success)

    tester.start!

    expect(Capybara.app_host).to eq("http://127.0.0.1:12345")
  end

  it "retries a connection refusal while the server boots" do
    expect(Net::HTTP).to receive(:start).ordered.and_raise(Errno::ECONNREFUSED)
    expect(Net::HTTP).to receive(:start).ordered.and_return(success)

    tester.start!
  end

  it "fails with container logs when readiness times out" do
    allow(tester).to receive(:monotonic_time).and_return(0, 100_000)
    allow(Net::HTTP).to receive(:start).and_return(unavailable)
    allow(compose).to receive(:run).with("logs", "--no-color", "--tail", "200").and_return("startup failed")

    expect { tester.start! }.to raise_error(/Container did not become ready:\nstartup failed/)
  end

  it "respects dependency startup order and refreshes the published port after stopping" do
    allow(Net::HTTP).to receive(:start).and_return(success)
    allow(compose).to receive(:run).with("port", "huginn", "3000").and_return("127.0.0.1:12345", "127.0.0.1:23456")
    allow(Capybara).to receive(:reset_sessions!)
    tester.start!

    expect(compose).to receive(:run).with("stop", "--timeout", "60").ordered
    expect(compose).to receive(:run).with("up", "--detach", "--pull", "never").ordered
    tester.restart!

    expect(Capybara.app_host).to eq("http://127.0.0.1:23456")
  end

  it "selects the agent requested by the caller" do
    allow(tester).to receive(:visit)
    allow(tester).to receive(:page).and_return(Capybara.string("Agent run queued for"))
    expect(tester).to receive(:click_on).with("Custom Agent", exact: true).ordered
    expect(tester).to receive(:click_on).with("Actions").ordered
    expect(tester).to receive(:click_on).with("Run", exact: true).ordered

    tester.run_agent(name: "Custom Agent")
  end
end
