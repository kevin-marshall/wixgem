require 'minitest/autorun'
require 'win32/registry'

require_relative '../lib/wixgem.rb'
require_relative 'test_methods/install_msi.rb'

class RegistryKey_test < Minitest::Test
  def test_set_registry_key
	msi = 'test/wixgem_registry_keys_file.msi'

	key = 'Software\\Microsoft\\DirectX\\UserGpuPreferences'
    #install_path = "#{File.dirname(__FILE__)}\\test\\write.exe"
	install_path = "C:\\Development\\wrk\\github\\wixgem\\tests\\test\\write.exe"
	
	Wixgem::Wix.make_installation(msi, 
		{ debug: true, set_registry_keys: 
			[{root: 'HKCU', key: key, 
			  value: { name: install_path, value: 'GpuPreference=2;', type: 'string'}}],
			  files: ['test_files/ReadOnly.txt']})
	assert(File.exists?(msi), "should create an installation file using: #{msi}")

	install_msi(msi) do |installdir|
	  entry = Win32::Registry::HKEY_CURRENT_USER.open(key, Win32::Registry::KEY_READ)
	  assert(!entry.nil?, "Registry key 'HKCU\\#{key}' does not exist")

	  key = entry.open(install_path, Win32::Registry::KEY_READ)
	  assert(!key.nil?, "Registry key 'HKCU\\#{path}\\#{install_path}' does not exist")
      entry.close
	end
  end 
end

