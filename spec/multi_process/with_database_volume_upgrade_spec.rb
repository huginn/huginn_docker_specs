require 'spec_helper'

RSpec.describe 'multi-process using an old database volume', type: :feature do
  context 'with the default configuration' do
    include_context 'with volume', data_source: './data/ubuntu-14-mysql'
    include_context 'default configuration', compose_file: 'multi_process/with_database_volume.yml', database_should_exist: true

    it 'does spawn the embedded mysql server' do
      expect(@ct).to have_log("success: mysqld entered RUNNING state")
    end

    it 'actually used the previous data' do
      @ct.login
      @ct.run_agent(name: 'Ubuntu14')
    end
  end
end
