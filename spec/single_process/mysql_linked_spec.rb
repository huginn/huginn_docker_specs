require 'spec_helper'

RSpec.describe 'single-process linked to mysql database', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'single_process/mysql_linked.yml'
  end
end
