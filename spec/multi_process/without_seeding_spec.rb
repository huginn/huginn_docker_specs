require 'spec_helper'

RSpec.describe 'multi-process linked to mysql database without seeding', type: :feature do
  before(:all) do
    @ct = ContainerTester.new(compose_file: 'multi_process/without_seeding.yml')
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
    expect(@ct).not_to have_log("Database 'huginn_production' already exists")
  end

  it 'does not seed the database' do
    expect(@ct).not_to have_log("NOTE: The example 'SF Weather Agent' will not work until you edit it and put in a free API key from http://www.wunderground.com/weather/api/")
  end
end
