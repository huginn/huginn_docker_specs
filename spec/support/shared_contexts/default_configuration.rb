RSpec.shared_context 'default configuration' do |compose_file:|
  before(:all) do
    @ct = ContainerTester.new(compose_file: compose_file)
    @ct.start!
  end

  after(:all) do
    @ct.rm!
  end

  it 'started all components' do
    @ct.login
    @ct.run_agent(name: 'XKCD Source')
    @ct.verify_events(name: 'XKCD Source')
  end

  it 'keeps event data between restarts' do
    @ct.restart!
    @ct.login
    @ct.verify_events(name: 'XKCD Source')
  end

  it 'does generate a random APP_SECRET_TOKEN' do
    expect(@ct).to have_log("Generating random APP_SECRET_TOKEN.")
  end

  it 'creates the database' do
    expect(@ct).to have_log("Created database 'huginn_production'")
  end

  it 'migrates the datbaase' do
    expect(@ct).to have_log("Migrating to")
  end
end
