require 'minitest/autorun'
require_relative '../lib/wixgem.rb'
require_relative '../lib/file.rb'
require_relative 'test_install.rb'
require_relative 'test_shortcut.rb'

class Shortcut_test < MiniTest::Unit::TestCase
  def test_creating_shortcuts
    test_arguments = [
	  {id: 'test1', msi: 'test/wixgem_create_shortcut_test1.msi', wix_hash: {debug: true, files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { :directory => :desktop }}}},
	  {id: 'test2', msi: 'test/wixgem_create_shortcut_test2.msi', wix_hash: {debug: true, files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { name: 'name', :directory => :desktop}}}},
	  {id: 'test3', msi: 'test/wixgem_create_shortcut_test3.msi', wix_hash: {debug: true, files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { name: 'name', arguments: '/test', :directory => :desktop}}}},
	  {id: 'test4', msi: 'test/wixgem_create_shortcut_test4.msi', wix_hash: {debug: true, files: ['test_files/32145.txt','test_files/Camera.ico'], shortcuts: {'test_files/32145.txt' => { name: 'name', icon: 'test_files/Camera.ico', :directory => :desktop}}}}
	  #{id: 'test5', msi: 'test/wixgem_create_shortcut_test5.msi', wix_hash: {files: ['test_files/32145.txt'], shortcuts: {'test_files/32145.txt' => { name: 'Menu Test', directory: :startup_menu}}}}	  
    ]
	
    test_arguments.each { |test| 
	  File.delete(test[:msi]) if(File.exists?(test[:msi]))
	
      Wixgem::Wix.make_installation(test[:msi], test[:wix_hash])
	  assert(File.exists?(test[:msi]), "should create an installation file using: #{test[:msi]}")	  
   
	  test_install(test[:id], test[:msi], test[:wix_hash], "test_shortcuts('#{test[:msi]}', #{test[:wix_hash]})") 
	}
  end 

  def shortcut_exceptions
    exception_test_arguments = [
     {id: 'test1', msi_file: 'test/wixgem_create_shortcut_exception_test1.msi', wix_hash: {files: ['test_files/32145.txt'], modify_file_paths: {/\Atest_files\// => ''}, shortcuts: {'test_files/32145.txt' => { :directory => :desktop }}}, error_msg: "does not exist" }
    ]
  
    exception_test_arguments.each { |test|
	  if(test.has_key?(:error_msg))
	    assert_exception(Proc.new { Wixgem::Wix.make_installation(test[:msi_file], test[:wix_hash]) }, test[:error_msg])
	  else
		assert_exception(Proc.new { Wixgem::Wix.make_installation(test[:msi_file], test[:wix_hash]) }, "#{test[:id]} should raise an exception")
	  end
    }
  end	
end

