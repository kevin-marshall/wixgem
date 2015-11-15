require 'minitest/autorun'

require_relative '../lib/wixgem.rb'
require_relative 'wixpath.rb'
require_relative 'test_file_attributes.rb'
require_relative 'test_install.rb'
require_relative '../lib/admin.rb'

class FileAttributes_test < MiniTest::Unit::TestCase
  def test_file_attributes
    test_arguments = {
	  test100: ['test/wixgem_read_only_test.msi', {modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob('test_files/*')}],
    }
	
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))
	
      Wixgem::Wix.make_installation(value[0], value[1])
	  assert(File.exists?(value[0]), "should create an installation file using: #{value[0]}")	  
   
      if(admin?)
	    test_install(key, value[0], value[1], "test_file_attributes('#{value[0]}', #{value[1]})") 
      end		
	}
  end  
end

