require 'minitest/autorun'
require 'WindowsInstaller'
require 'win32ole'

require_relative '../lib/wixgem.rb'
require_relative 'test_files_exist.rb'
require_relative 'test_file_attributes.rb'
require_relative 'assert_exception.rb'
require_relative 'install_msi'
	
class CustomAction_test < MiniTest::Unit::TestCase
  def test_Installation
    output = { 
	  test0: "#{File.dirname(__FILE__)}/test/binary_table.txt",
	  test1: "#{File.dirname(__FILE__)}/test/file_after_install.txt",
	}

    test_arguments = {
      test0: { msi: 'test/wixgem_custom_action_test1.msi', 
	           input: {files: ['all_tests.rb'],
			           debug: true,
	                   binary_table: [{ id: 'binary_table', file: 'CustomActionExe/hello_world.exe' }],
		               custom_actions: [ {binary_key: 'binary_table', exe_command: output[:test0]} ]}},
	  test1: { msi: 'test/wixgem_custom_action_test2.msi',
	           input: {files: ['CustomActionExe/hello_world.exe'],
			           debug: true,
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [ {file: 'hello_world.exe', exe_command: output[:test1] } ]}}
    }
	
    test_arguments.each do |test_id, test_data| 
	  File.delete(test_data[:msi]) if(File.exists?(test_data[:msi]))
	  File.delete(output[test_id]) if(File.exists?(output[test_id]))
	
      Wixgem::Wix.make_installation(test_data[:msi], test_data[:input])
	  assert(File.exists?(test_data[:msi]), "Should have created an installation file: #{test_data[:msi]}") 
    
	  install_msi(test_data[:msi], test_data[:input]) do |install_path| 
	    assert(File.exists?(output[test_id], "Custom action should have created file: #{output[test_id]}")) 
	  end
	end
  end  
end
