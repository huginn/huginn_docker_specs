require 'spec_helper'

RSpec.describe 'single-process with dotenv configuration', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'single_process/with_dot_env_configuration.yml'

    it "loads the timezone from the env file" do
      expect(@ct.rails('puts "TIMEZONE=" + ENV.fetch("TIMEZONE")')).to include("TIMEZONE=Berlin")
    end
  end
end
