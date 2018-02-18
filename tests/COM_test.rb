require 'minitest/autorun'

require_relative '../lib/wixgem.rb'
require_relative 'test_files_exist.rb'
require_relative 'assert_exception.rb'
require 'win32ole'
require_relative '../lib/admin.rb'
require_relative 'test_msi.rb'

class COMInstaller_test < Minitest::Test

  def test_harvest_registry
    if(admin?)
	  assert_exception(Proc.new { WIN32OLE.new('COMObject.ComClassExample') }, 'should not be able to instance a COM object')

	  installation_file = 'test\\wixgem_harvest_registry.msi'	
 	  installation_hash = { debug: true, all_users: 'perMachine', files: ['COMObject/bin/Release/COMObject.dll'],  modify_file_paths: {/.+Release\// => ''}}

      Wixgem::Wix.make_installation(installation_file, installation_hash)
	  assert(File.exists?(installation_file), "should create an installation file using: #{installation_file}")	  
    
	  test_msi(installation_file) do
        test_files_exist(installation_file, installation_hash)

		# Unable to get working? Is there an issue with win32ole and 64bit?
		#object = WIN32OLE.new('TestCOMObject.ComClassExample')
	    #assert(!object.nil?)
		#assert(object.GetText() == 'Hello World')
	  end
    end
  end
  def test_self_register
    if(admin?)
	  assert_exception(Proc.new { WIN32OLE.new('COMObject.ComClassExample') }, 'should not be able to instance a COM object')

	  installation_file = 'test\\wixgem_self_register.msi'	
 	  installation_hash = { debug: true, all_users: 'perMachine', 
	                       files: ['COMObject.dll'], 
						   com_self_register: ['COMObject.dll'],  
						   modify_file_paths: {/.+Release\// => ''},
						   suppress_registry_harvesting: true}

      Wixgem::Wix.make_installation(installation_file, installation_hash)
	  assert(File.exists?(installation_file), "should create an installation file using: #{installation_file}")	  
#    
#	  test_msi(installation_file) do
#        test_files_exist(installation_file, installation_hash)

		# Unable to get working? Is there an issue with win32ole and 64bit?
		#object = WIN32OLE.new('TestCOMObject.ComClassExample')
	    #assert(!object.nil?)
		#assert(object.GetText() == 'Hello World')
	  end
    end
end

