require 'minitest/autorun'
require('WindowsInstaller')

require_relative '../lib/wixgem.rb'
require_relative 'test_files_exist.rb'
require_relative 'assert_exception.rb'
require_relative '../lib/admin.rb'

class COMInstaller_test < MiniTest::Unit::TestCase

  def test_installation_of_a_COM_object
    if(admin?)
	  assert_exception(Proc.new { WIN32OLE.new('COMObject.ComClassExample') }, 'should not be able to instance a COM object')

	  installation_file = 'test\\wixgem_com_test.msi'	
 	  installation_hash = { debug: true, all_users: 'perMachine', files: ['../COMObject/bin/AnyCPU/Release/COMObject.dll'],  modify_file_paths: {/.+Release\// => ''}}

      Wixgem::Wix.make_installation(installation_file, installation_hash)
	  assert(File.exists?(installation_file), "should create an installation file using: #{installation_file}")	  
    
	  installer = WindowsInstaller.new
	  intaller.install_msi(installation_file)
	  assert(intaller.msi_installed?(installation_file), 'Should have installed wixgem_com_test.msi')

      test_files_exist(installation_file, installation_hash)
	  
	  # Allocating the COM object causes an issue when the install package is uninstalled.
	  # The msiexec reports Interrupt again to exit immediately. Need to spend some more
	  # time understanding what is going on with the uninstaller.
	  
	  # it 'should be able to instance a COM object with a GUID' do
		# object = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
		# expect(object.nil?).to eq(false)
		# expect(object.GetText).to eq('Hello World')
	  # end

#	  it 'should be able to instance a COM object with a Program Id' do		
#		object = WIN32OLE.new('COMObject.ComClassExample')
#		expect(object.nil?).to eq(false)
#		expect(object.GetText).to eq('Hello World')
#	  end

	  intaller.uninstall_msi(installation_file)
	  assert(!intaller.msi_installed?(installation_file), 'Should have uninstalled wixgem_com_test.msi')
    end
	
	Wixgem::WindowsInstaller.uninstall(installation_file) if(Wixgem::WindowsInstaller.msi_installed?(installation_file))
  end
  def test_install_COM_object1
    if(admin?)
	  assert_exception(Proc.new { WIN32OLE.new('COMObject.ComClassExample') }, 'should not be able to instance a COM object')

	  installation_file = 'test\\wixgem_com_test.msi'	
 	  installation_hash = { debug: true, all_users: 'perMachine', com_files: ['../COMObject/bin/AnyCPU/Release/COMObject.dll'], files: ['../COMObject/bin/AnyCPU/Release/COMObject.dll'],  modify_file_paths: {/.+Release\// => ''}}

      Wixgem::Wix.make_installation(installation_file, installation_hash)
	  assert(File.exists?(installation_file), "should create an installation file using: #{installation_file}")	  
    
	  Wixgem::WindowsInstaller.install(installation_file)
	  assert(Wixgem::WindowsInstaller.msi_installed?(installation_file), 'should install')

      test_files_exist(installation_file, installation_hash)
	
	  # Allocating the COM object causes an issue when the install package is uninstalled.
	  # The msiexec reports Interrupt again to exit immediately. Need to spend some more
	  # time understanding what is going on with the uninstaller.
	  
	  # it 'should be able to instance a COM object with a GUID' do
		# object = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
		# expect(object.nil?).to eq(false)
		# expect(object.GetText).to eq('Hello World')
	  # end

#	  it 'should be able to instance a COM object with a Program Id' do		
#		object = WIN32OLE.new('COMObject.ComClassExample')
#		expect(object.nil?).to eq(false)
#		expect(object.GetText).to eq('Hello World')
#	  end
    end
	
	Wixgem::WindowsInstaller.uninstall(installation_file) if(Wixgem::WindowsInstaller.msi_installed?(installation_file))
  end
end

