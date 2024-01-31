require 'minitest/autorun'
require 'win32/registry'

require_relative '../lib/wixgem.rb'
require_relative 'test_methods/install_msi.rb'

class RegistryKey_test < Minitest::Test
  def test_set_registry_key
	msi = 'test/wixgem_registry_keys_file.msi'

	key = "SOFTWARE\\Microsoft\\DirectX\\UserGpuPreferences"
	key1 = 'SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps\\Aim.exe'
    install_path = "C:\\Program Files (x86)\\wixgem_registry_keys_file"
	
	Wixgem::Wix.make_installation(msi, 
		{ debug: true, set_registry_keys: 
			[
			  {root: 'HKCU', key: key, 
			   value: { name: '[ARPINSTALLLOCATION]', value: 'GpuPreference=2;', type: 'string'}},
			  {root: 'HKCU', key: key1, 
			   value: {name: 'DumpFolder', value: '%localappdata%\\Musco\\Aim2\\UserCrashDump',type: 'string'}}],
			  files: ['test_files/ReadOnly.txt']})
	assert(File.exist?(msi), "should create an installation file using: #{msi}")

	install_msi(msi) do |installdir|
	  entry = Win32::Registry::HKEY_CURRENT_USER.open(key, Win32::Registry::KEY_READ)
	  assert(!entry.nil?, "Registry key 'HKCU\\#{key}' does not exist")
      entry.close

	  entry = Win32::Registry::HKEY_CURRENT_USER.open(key1, Win32::Registry::KEY_READ)
	  assert(!entry.nil?, "Registry key 'HKLM\\#{key1}' does not exist")
      entry.close

	  # Currently not working, but the registry is working
	  assert(Dir.exist?(install_path), "'#{install_path}' does not exist")
	end
  end 
end

