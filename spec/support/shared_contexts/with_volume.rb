RSpec.shared_context 'with volume' do |data_source: nil|
  before(:all) do
    `docker volume rm huginn-docker-specs-mysql`
    `docker volume create huginn-docker-specs-mysql`
     if data_source
      `docker run -it --rm -v $(pwd)/data:/data -v huginn-docker-specs-mysql:/var/lib/mysql busybox tar xf /data/#{data_source} -C /var/lib/mysql`
     end
    `docker run -it --rm -v $(pwd)/data:/data -v huginn-docker-specs-mysql:/var/lib/mysql busybox chown -R 1001 /var/lib/mysql`
  end

  after(:all) do
    `docker volume rm huginn-docker-specs-mysql`
  end
end
