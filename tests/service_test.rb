require 'minitest/autorun'
require_relative '../lib/wixgem.rb'
require_relative '../lib/file.rb'
require_relative 'test_methods/install_msi.rb'
require_relative 'test_methods/test_service.rb'

class Services_test < Minitest::Test
  def test_install_service
    files = Dir.glob('WindowsService/bin/Release/**/*')
    test_arguments = [
      {
        id: 'test1', msi: 'test/wixgem_create_service_test1.msi', 
        wix_hash: {
          files: files.to_ary, 
          services: [{
            service_exe: 'WindowsService.exe', 
            service: { name: 'Wixgem Service', type: 'ownProcess', start: 'auto' },
            service_control: {start: 'install', stop: 'both', remove: 'uninstall', wait: 'yes'}
          }],
          modify_file_paths: { /^.+Release\// => ''}}
      }
    ]

    test_arguments.each { |test| 
	    File.delete(test[:msi]) if(File.exists?(test[:msi]))
	
      Wixgem::Wix.make_installation(test[:msi], test[:wix_hash])
	    assert(File.exists?(test[:msi]), "should create an installation file using: #{test[:msi]}")	  
   
      install_msi(test[:msi]) { |install_dir| test_service(test[:msi], test[:wix_hash]) } 
      sleep(0.5)
	  }
  end 
end

