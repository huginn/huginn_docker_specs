class ContainerTester
  include Capybara::DSL
  include RSpec::Matchers

  def initialize(compose_file:)
    @runner = Backticks::Runner.new(buffered: [:stderr])
    @compose = Docker::Compose::Session.new(@runner, file: root.join('spec', compose_file))
  end

  def start!
    @compose.up(detached:true)
    wait_until_started
  end

  def restart!
    @compose.restart(timeout: 0)
    wait_until_started
  end

  def rm!
    @compose.stop(timeout: 0)
    @compose.rm(force: true, volumes: true)
  end

  def login(username: 'admin', password: 'password')
    visit '/'
    click_on 'Login'
    fill_in 'Login', with: username
    fill_in 'Password', with: password
    click_on 'Log in'
    expect(page).to have_content('Signed in successfully.')
  end

  def run_agent(name:)
    click_on 'Agents'
    expect(page).to have_content(name)
    click_on 'XKCD Source'
    click_on 'Actions'
    click_on 'Run'
    expect(page).to have_content('Agent run queued for')
  end

  def verify_events(name:)
    wait_for_event
    expect(page).to have_content(name)
  end

  def logs
    @compose.logs('huginn')
  end

  def capture_stdout
    output = StringIO.new
    $stdout = output
    yield
    $stdout = STDOUT
    output
  end


  def wait_until_started
    i = 0
    loop do
      visit "/"
      i += 1
      break if page.status_code

      if i >= 120
        puts logs
        raise 'Container did not boot witnin 120 seconds'
      end
      sleep 1
    end
  end

  private

  def wait_for_event
    i = 0
    while i <= 60
      visit '/events'
      return if page.has_selector? 'table tr:nth-child(2)'
      i += 1
      sleep 1
    end
    raise 'No Event found'
  end
end
