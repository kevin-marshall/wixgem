require './lib/command.rb'

def admin?
  cmd = Command.new('net session')
  cmd[:ignore_exit_code] = true
  cmd.execute
  return true if(cmd[:exit_status] == 0)
  return false
end
