require 'cmd'

executable = ENV['OCRA_EXECUTABLE']
executable = $0 if(executable.nil?)

def admin?
  cmd = CMD.new('net session')
  cmd[:ignore_exit_code] = true
  cmd[:quiet] = true#  cmd.execute
  return true if(cmd[:exit_code] == 0)
  return false
end

text = ''
text << "admin: #{admin?}\n"
text << "argumens: #{ARGV.join}"
file="#{File.dirname(executable)}/hello_world.txt"    
File.open(file, 'w') { |f| f.write(text) } unless defined?(Ocra)
