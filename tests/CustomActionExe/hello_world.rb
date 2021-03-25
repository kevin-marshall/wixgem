executable = ENV['OCRA_EXECUTABLE']
executable = $0 if(executable.nil?)

def admin?
  rights=%x[whoami /priv]
  return rights.include?('SeCreateGlobalPrivilege')
end

text = ''
text << "admin: #{admin?}"

File.open(ARGV[0], 'w') { |f| f.write(text) } unless defined?(Ocra)
