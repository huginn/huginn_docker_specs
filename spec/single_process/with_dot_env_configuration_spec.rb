require 'spec_helper'

RSpec.describe 'single-process linked to postgresql database', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'single_process/with_dot_env_configuration.yml'
  end
end
