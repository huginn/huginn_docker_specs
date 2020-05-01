RSpec.shared_context 'with volume' do |data_source: nil|
  before(:all) do
    FileUtils.rm_rf File.join(Dir.pwd, 'spec', 'mysql-data')
    if data_source
      FileUtils.cp_r File.join(Dir.pwd, data_source), File.join(Dir.pwd, 'spec', 'mysql-data')
    end
  end

  after(:all) do
    FileUtils.rm_rf File.join(Dir.pwd, 'spec', 'mysql-data')
  end
end
