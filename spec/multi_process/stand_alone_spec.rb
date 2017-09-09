require 'spec_helper'

RSpec.describe 'multi-process standalone', type: :feature do
  context 'with the default configuration' do
    include_context 'default configuration', compose_file: 'multi_process/stand-alone.yml'

    it 'does spawn the embedded mysql server' do
      expect(@ct).to have_log("success: mysqld entered RUNNING state")
    end
  end
end
