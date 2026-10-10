require "rake"
require "rspec/core/rake_task"
require_relative "spec/support/compose"

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:unit) do |task|
  task.pattern = "spec/unit/**/*_spec.rb"
end

desc "Validate all Docker Compose fixtures"
task :compose do
  Dir[File.join(__dir__, "spec/{multi_process,single_process}/*.yml")].sort.each do |file|
    Compose.new(file: file).run("config", "--quiet")
  end
end

task default: [:compose, :spec]
