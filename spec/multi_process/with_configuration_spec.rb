require 'spec_helper'

RSpec.describe 'multi-process linked to mysql database with configuration', type: :feature do
  before(:all) do
    @ct = ContainerTester.new(compose_file: 'multi_process/with_configuration.yml')
    @ct.start!
  end

  after(:all) do
    @ct.rm!
  end

  it 'started all components' do
    @ct.wait_until_started
  end

  it 'does not spawn the embedded mysql server' do
    expect(@ct).not_to have_log("success: mysqld entered RUNNING state")
  end

  it 'does not try to create the database' do
    expect(@ct).not_to have_log("Created database")
    expect(@ct).not_to have_log("Database 'huginn_production' already exists")
  end

  it 'uses the secret token from the configuration' do
    expect(@ct).not_to have_log("Generating random APP_SECRET_TOKEN.")
  end

  it 'does not seed the database' do
    expect(@ct.records).to eq("users" => 0, "agents" => 0)
  end

  it 'does install the specified agent gems' do
    output = @ct.rails('puts Gem.loaded_specs.keys.grep(/\Ahuginn_(?:website_metadata|readability)_agent\z/)')
    expect(output).to include("huginn_website_metadata_agent", "huginn_readability_agent")
  end
end
