RSpec.shared_context 'with volume' do |data_source: nil|
  before(:all) do
    volume = File.join(Dir.pwd, 'spec', 'mysql-data')
    `sudo rm -rf #{volume}`
    FileUtils.mkdir_p volume
    if data_source
      `sudo cp -r #{File.join(Dir.pwd, data_source)}/* #{volume}`
    end
    `sudo chown 1001 -R #{volume}`
  end

  after(:all) do
    volume = File.join(Dir.pwd, 'spec', 'mysql-data')
    `sudo rm -rf #{volume}`
  end
end
