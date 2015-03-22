require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_shortcut.rb'

describe 'Wixgem' do
  describe 'creating shortcuts' do
    test_arguments = [
	  {id: 'test1', msi: 'test/wixgem_create_shortcut_test1.msi', wix_hash: {files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { :directory => :desktop }}}},
	  {id: 'test2', msi: 'test/wixgem_create_shortcut_test2.msi', wix_hash: {files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { name: 'name', :directory => :desktop}}}},
	  {id: 'test3', msi: 'test/wixgem_create_shortcut_test3.msi', wix_hash: {files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { name: 'name', arguments: '/test', :directory => :desktop}}}}
    ]
	
    test_arguments.each { |test| 
	  File.delete(test[:msi]) if(File.exists?(test[:msi]))
	
	  it "should create an installation file using: #{test[:msi]}" do
        Wixgem::Wix.make_installation(test[:msi], test[:wix_hash])
	    expect(File.exists?(test[:msi])).to be(true)	  
	  end
   
	  it "should install and uninstall: #{test[:msi]}" do
	    test_install(test[:id], test[:msi], test[:wix_hash], "test_shortcuts('#{test[:msi]}', #{test[:wix_hash]})") 
	  end	  
	}
  end 

  describe 'shortcut exceptions' do 
    exception_test_arguments = [
     {id: 'test1', msi_file: 'test/wixgem_create_shortcut_exception_test1.msi', wix_hash: {files: ['test_files/32145.txt'], modify_file_paths: {/\Atest_files\// => ''}, shortcuts: {'test_files/32145.txt' => { :directory => :desktop }}}, error_msg: "does not exist" }
    ]
  
    exception_test_arguments.each { |test|
	  it "#{test[:id]} should raise an exception" do
	    if(test.has_key?(:error_msg))
			expect { Wixgem::Wix.make_installation(test[:msi_file], test[:wix_hash]) }.to raise_error(/#{test[:error_msg]}/)
		else
			expect { Wixgem::Wix.make_installation(test[:msi_file], test[:wix_hash]) }.to raise_error
		end
	  end
    }
  end	
  
end