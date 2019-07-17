def os_x64?
	return false unless(ENV.has_key?('ProgramFiles(x86)'))
	return true
end

def get_user(wix_hash, user)
  raise 'Currently not supporting 32 bit OS' unless(os_x64?)
  return user[:name]
end

def test_user(wix_hash, name, user_element)
  puts "Username: #{name}"
end

def test_users(msi, wix_hash)
  wix_hash[:users].each { |name,user| test_user(wix_hash, name, wix_hash[:users][name]) }  
end