require 'minitest/autorun'
require 'win32/registry'

require_relative '../lib/wixgem.rb'
require_relative 'test_methods/install_msi.rb'

class RegistryKey_test < Minitest::Test
  def test_set_registry_key
	msi = 'test/wixgem_registry_keys_file.msi'

	root = 'HKEY_CURRENT_USER'
	path = 'Software\\Microsoft\\DirectX\\UserGpuPreferences'

	Wixgem::Wix.make_installation(msi, 
		{ debug: true, set_registry_keys: 
			[{'root' => root,'path' => path, 
			  'key' => {'name'=>'GpuPreference','value'=> '2','value type'=>'DWORD'}}],
			  files: ['test_files/ReadOnly.txt']})
	assert(File.exists?(msi), "should create an installation file using: #{msi}")

	install_msi(msi) do |installdir|
	  entry = Win32::Registry::HKEY_CURRENT_USER.open(path, Win32::Registry::KEY_READ)
	  assert(!entry.nil?, "Registry key 'HKEY_CURRENT_USER\\#{path}' does not exist")
      entry.close
	end
  end 
end

