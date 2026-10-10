class ContainerTester
  include Capybara::DSL
  include RSpec::Matchers

  SEED_PASSWORD = "Docker specs password 2026".freeze

  def initialize(compose_file:)
    @compose = Compose.new(file: root.join("spec", compose_file))
  end

  def start!
    pull_policy = ENV.fetch("HUGINN_PULL_POLICY", "always")
    @compose.run("up", "--detach", "--pull", pull_policy, "--quiet-pull")
    wait_until_started
  end

  def restart!
    Capybara.reset_sessions!
    @compose.run("stop", "--timeout", "60")
    @compose.run("up", "--detach", "--pull", "never")
    wait_until_started
  end

  def recreate!
    Capybara.reset_sessions!
    @compose.run("down", "--timeout", "60")
    start!
  end

  def rm!
    Capybara.reset_sessions!
    @compose.run("down", "--volumes", "--remove-orphans", "--timeout", "60")
  end

  def login(username: "admin", password: SEED_PASSWORD)
    visit "/users/sign_in"
    fill_in "Login", with: username
    fill_in "Password", with: password
    click_on "Log in"
    expect(page).to have_content("Signed in successfully.")
  end

  def prepare_agent
    rails(<<~RUBY)
      agent = Agents::WebsiteAgent.find_by!(name: "XKCD Source")
      agent.update!(options: {
        "url" => "http://fixture",
        "mode" => "on_change",
        "expected_update_period_in_days" => 5,
        "extract" => {"title" => {"css" => "title", "value" => "string(.)"}}
      })
    RUBY
  end

  def run_agent(name:)
    visit "/agents"
    click_on name, exact: true
    click_on "Actions"
    click_on "Run", exact: true
    expect(page).to have_content("Agent run queued for")
  end

  def verify_events(name:)
    deadline = monotonic_time + 120
    loop do
      visit "/events"
      return if page.has_selector?("table tbody tr", text: name, wait: 1)

      raise "No event from #{name} within 120 seconds:\n#{logs(tail: 200)}" if monotonic_time >= deadline

      sleep 1
    end
  end

  def logs(tail: nil)
    arguments = ["logs", "--no-color"]
    arguments.concat(["--tail", tail.to_s]) if tail
    @compose.run(*arguments)
  end

  def rails(code)
    @compose.run("exec", "-T", "huginn", "bundle", "exec", "rails", "runner", code)
  end

  def records
    output = rails('puts "HUGINN_SPEC_RESULT=" + JSON.generate(users: User.count, agents: Agent.count)')
    line = output.lines.find { |item| item.start_with?("HUGINN_SPEC_RESULT=") }
    raise "Missing record counts in rails runner output" unless line

    JSON.parse(line.delete_prefix("HUGINN_SPEC_RESULT="))
  end

  def wait_until_started
    address = @compose.run("port", "huginn", "3000").strip
    @url = "http://#{address}"
    Capybara.app_host = @url
    deadline = monotonic_time + Integer(ENV.fetch("HUGINN_BOOT_TIMEOUT", "300"), 10)
    uri = URI("#{@url}/users/sign_in")
    loop do
      begin
        response = Net::HTTP.start(
          uri.hostname, uri.port, nil, open_timeout: 2, read_timeout: 2
        ) { |http| http.get(uri.request_uri) }
        return if response.is_a?(Net::HTTPSuccess)
      rescue IOError, SystemCallError, Timeout::Error, Net::HTTPBadResponse, Net::ProtocolError
        # The port can be published before Puma is ready to serve requests.
      end

      raise "Container did not become ready:\n#{logs(tail: 200)}" if monotonic_time >= deadline

      sleep 1
    end
  end

  private

  def monotonic_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
