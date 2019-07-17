require 'minitest/autorun'
require_relative '../lib/wixgem.rb'
require_relative '../lib/user.rb'

require_relative 'test_methods/install_msi.rb'
require_relative 'test_methods/test_user.rb'

class User_test < Minitest::Test
  def test_creating_a_user
    test_arguments = [
	    {id: 'user1', msi: 'test/wixgem_create_user.msi', wix_hash: {files: ['test_files/32145.txt'], debug: true, users: { 'WixTestUser': {'Password': 'This is a test', 'CreateUser': 'yes', 'Domain': ENV['COMPUTERNAME'], 'RemoveOnUninstall': 'yes', 'Disabled': 'yes'}}}},
    ]
	
    test_arguments.each { |test| 
	    File.delete(test[:msi]) if(File.exists?(test[:msi]))
	
        Wixgem::Wix.make_installation(test[:msi], test[:wix_hash])
	    assert(File.exists?(test[:msi]), "should create an installation file using: #{test[:msi]}")	  
   
        install_msi(test[:msi]) { |install_dir| test_users(test[:msi], test[:wix_hash]) } 
        sleep(0.5)
	  }
  end 
end

