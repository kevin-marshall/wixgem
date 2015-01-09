require 'dev_tasks'

def execute(cmd)
  command = Command.new(cmd)
  command.execute
  
  raise "Failed: #{cmd} Status: #{command[:exit_code]}\nStdout: #{command[:output]}\nStderr: #{command[:error]}" unless(command[:exit_code] == 0)
end
