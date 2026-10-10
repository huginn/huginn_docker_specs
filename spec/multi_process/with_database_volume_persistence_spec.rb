require "spec_helper"

RSpec.describe "multi-process with a persisted database volume", type: :feature do
  before(:all) do
    @ct = ContainerTester.new(compose_file: "multi_process/with_database_volume.yml")
    @ct.start!
    @ct.login
    @ct.prepare_agent
    @ct.run_agent(name: "XKCD Source")
    @ct.verify_events(name: "XKCD Source")
    @records = @ct.records
    @ct.recreate!
  end

  after(:all) do
    @ct.rm!
  end

  it "keeps users, agents, and events when containers are recreated" do
    @ct.login
    @ct.verify_events(name: "XKCD Source")
    expect(@ct.records).to eq(@records)
  end
end
