require 'spec_helper'

RSpec.describe 'single-process with separate AgentRunner and job containers', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'single_process/with_separate_containers.yml'
  end
end
