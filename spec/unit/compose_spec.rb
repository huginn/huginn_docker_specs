require "spec_helper"

RSpec.describe Compose do
  subject(:compose) { described_class.new(file: "/tmp/path with spaces/compose.yml") }

  it "passes literal arguments to the Compose plugin without a shell" do
    status = instance_double(Process::Status, success?: true)
    expect(Open3).to receive(:capture3).with(
      "docker", "compose", "--project-name", compose.project,
      "--file", "/tmp/path with spaces/compose.yml", "exec", "-T", "huginn",
      "ruby", "-e", 'puts "$literal; `literal`"'
    ).and_return(["output", "", status])

    expect(compose.run("exec", "-T", "huginn", "ruby", "-e", 'puts "$literal; `literal`"')).to eq("output")
  end

  it "reports nonzero exits with both output streams" do
    status = instance_double(Process::Status, success?: false, exitstatus: 17)
    allow(Open3).to receive(:capture3).and_return(["stdout", "stderr", status])

    expect { compose.run("up") }.to raise_error(/failed \(17\):\nstderr\nstdout/)
  end

  it "uses a separate Compose project for each fixture" do
    other = described_class.new(file: "/tmp/compose.yml")

    expect(compose.project).to match(/\Ahuginn-specs-\d+-[a-f0-9]+\z/)
    expect(other.project).not_to eq(compose.project)
  end
end
