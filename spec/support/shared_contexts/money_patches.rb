# Fix warnings on ruby 2.4
module Backticks
  class Command
    def initialize(pid, stdin, stdout, stderr, interactive:false)
      @pid = pid
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @interactive = !!interactive
      @tap = nil
      @status = nil
      @captured_input  = String.new.force_encoding(Encoding::BINARY)
      @captured_output = String.new.force_encoding(Encoding::BINARY)
      @captured_error  = String.new.force_encoding(Encoding::BINARY)
    end
  end
end

# Instead of returning true on success return the logs
module Docker::Compose
  class Session
    def logs(*services)
      run!('logs', services)
    end
  end
end
