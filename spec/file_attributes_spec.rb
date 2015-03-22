require 'rspec'
require './admin.rb'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_file_attributes.rb'

describe 'Wixgem' do
  describe 'test file attributes' do
    test_arguments = {
	  test100: ['test/wixgem_read_only_test.msi', {modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob('test_files/*')}],
    }
	
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))
	
	  it "should create an installation file using: #{value[0]}" do
        Wixgem::Wix.make_installation(value[0], value[1])
	    expect(File.exists?(value[0])).to be(true)	  
	  end
   
      if(admin?)
	    it "should install and uninstall: #{value[0]}" do
	      test_install(key, value[0], value[1], "test_file_attributes('#{value[0]}', #{value[1]})") 
	    end
      end		
	}
  end  
end