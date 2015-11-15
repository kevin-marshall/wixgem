require_relative '../lib/command.rb'

def admin?
  cmd = Wixgem::Command.new('net session')
  cmd[:ignore_exit_code] = true
  cmd[:quiet] = true
  cmd.execute
  return true if(cmd[:exit_code] == 0)
  return false
end
ENV['HOME'] ||= "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if(admin?)
