require 'spec_helper'

RSpec.describe 'multi-process linked to postgresql database', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'multi_process/postgresql_linked.yml'

    it 'does not spawn the embedded mysql server' do
      expect(@ct).not_to have_log("success: mysqld entered RUNNING state")
    end
  end
end
