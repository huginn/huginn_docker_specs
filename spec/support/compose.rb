require "open3"
require "securerandom"

class Compose
  attr_reader :project

  def initialize(file:)
    @file = file.to_s
    @project = "huginn-specs-#{Process.pid}-#{SecureRandom.hex(4)}"
  end

  def run(*arguments)
    command = ["docker", "compose", "--project-name", project, "--file", @file, *arguments]
    stdout, stderr, status = Open3.capture3(*command)
    return stdout if status.success?

    raise "docker compose #{arguments.first} failed (#{status.exitstatus}):\n#{stderr}\n#{stdout}"
  end
end
