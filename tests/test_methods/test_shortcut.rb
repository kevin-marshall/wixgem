def os_x64?
	return false unless(ENV.has_key?('ProgramFiles(x86)'))
	return true
end

def get_shortcut_path(wix_hash, shortcut)
  raise 'Currently not supporting 32 bit OS' unless(os_x64?)
  case(shortcut[:directory])
  when :desktop
	path = (wix_hash[:all_users] == 'perMachine') ? ENV['PUBLIC'] : ENV['USERPROFILE']
	path = path.gsub(/\\/,'/')
    return "#{path}/Desktop"
  else
    raise "Cannot retrieve shortcut path for directory type #{:directory.to_s}"
  end
end

def test_shortcut(file, wix_hash, shortcut)
  shortcut_name = "#{shortcut[:name]}.lnk"
  shortcut_path = "#{get_shortcut_path(wix_hash, shortcut)}/#{shortcut_name}"
  #puts "Path: #{shortcut_path}"
  raise "#{shortcut_path} does not exist" unless(File.exist?(shortcut_path))
end

def test_shortcuts(msi, wix_hash)
  wix_hash[:shortcuts].each { |file,shortcut| test_shortcut(file,wix_hash,shortcut) }  
end