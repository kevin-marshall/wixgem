require 'minitest/autorun'
require 'win32/registry'

require_relative '../lib/wixgem.rb'
require_relative 'test_methods/install_msi.rb'

class AssociationExtension_test < Minitest::Test
  def test_associate_extension
	  msi = 'test/wixgem_associate_file1.msi'
    Wixgem::Wix.make_installation(msi, {debug: true, files: ['CustomActionExe/hello_world.exe'], extensions: {'CustomActionExe/hello_world.exe' => '.ext'}})
	  assert(File.exists?(msi), "should create an installation file using: #{msi}")

	  registry = 'HKEY_LOCAL_MACHINE'
	  key = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\hello_world.exe"
	  install_msi(msi) do |installdir|
	    entry = Win32::Registry::HKEY_LOCAL_MACHINE.open(key, Win32::Registry::KEY_READ)
	    assert(!entry.nil?, "Registry key '#{key}' does not exist")
      entry.close
	  end
  end 
end

