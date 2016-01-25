require 'execute'

def admin?
  cmd = Execute.new('net session')
  cmd[:ignore_exit_code] = true
  cmd[:quiet] = true
  cmd.execute
  return true if(cmd[:exit_code] == 0)
  return false
end
ENV['HOME'] = ENV['USERPROFILE'] if(admin?)
