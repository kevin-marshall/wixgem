require 'rspec'

def os_x64?
	return false unless(ENV.has_key?('ProgramFiles(x86)'))
	return true
end

def get_shortcut_path(shortcut)
  raise 'Currently not supporting 32 bit OS' unless(os_x64?)
  return "#{ENV['HOME']}\\Desktop" if(shortcut.has_key?(:directory) && (shortcut[:directory] == :desktop))
end

def test_shortcut(file, shortcut)
  shortcut_path = "#{get_shortcut_path(shortcut)}\\#{File.basename(file)}"
  #puts "Path: #{shortcut_path}"
  #raise "#{shortcut_path} does not exist" unless(File.exists?(shortcut_path))
end

def test_shortcuts(msi, wix_hash)
  wix_hash[:shortcuts].each { |file,shortcut| test_shortcut(file,shortcut) }  
end