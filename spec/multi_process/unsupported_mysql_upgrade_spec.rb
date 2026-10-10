require "spec_helper"

RSpec.describe "multi-process MySQL upgrade guard" do
  it "refuses a MySQL 5.7 volume that needs an intermediate upgrade" do
    compose = Compose.new(file: root.join("spec/multi_process/stand-alone.yml"))
    script = <<~RUBY
      require "tmpdir"
      Dir.mktmpdir do |directory|
        File.binwrite(File.join(directory, "ib_logfile0"), "\\0" * 16 + "MySQL5.7.44".ljust(32, "\\0"))
        system("/scripts/upgrade-mysql", directory)
        exit($?.exitstatus)
      end
    RUBY

    begin
      expect {
        compose.run("run", "--rm", "--no-deps", "--pull", ENV.fetch("HUGINN_PULL_POLICY", "always"),
                    "huginn", "ruby", "-e", script)
      }.to raise_error(/MySQL 5\.7\.44 data requires an intermediate upgrade to MySQL 8\.0 before 8\.4/)
    ensure
      compose.run("down", "--volumes", "--remove-orphans")
    end
  end
end
