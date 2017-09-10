require 'spec_helper'

RSpec.describe 'multi-process linked to postgresql database and separate', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'single_process/with_separate_containers.yml'
  end
end
