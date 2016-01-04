require 'minitest/autorun'
require 'WindowsInstaller'
require 'win32ole'

require_relative '../lib/wixgem.rb'
require_relative 'test_files_exist.rb'
require_relative 'test_file_attributes.rb'
require_relative 'assert_exception.rb'
require_relative 'install_msi.rb'
	
class CustomAction_test < MiniTest::Unit::TestCase
  def test_installation
    dir = File.absolute_path(File.dirname(__FILE__))
    output = { 
	  binary_table: "#{dir}/test/binary_table.txt",
	  before_inst_finalize: "#{dir}/test/file_before_install_finalize.txt",
	  after_inst_initialize: "#{dir}/test/file_after_install_finalize.txt",
	  before_remove_files: "#{dir}/test/file_before_remove_files.txt",
	  quiet_execution_ca: "#{dir}/test/write.exe"
	}

    test_arguments = {
      test1: { msi: 'test/wixgem_custom_action_test1.msi', 
	           input: {files: ['all_tests.rb'],
	                   binary_table: [{ id: 'binary_table', file: 'CustomActionExe/hello_world.exe' }],
	               custom_actions: [ {binary_key: 'binary_table', exe_command: output[:binary_table]} ]},
			   post_installation: [:binary_table]},
	 test2: { msi: 'test/wixgem_custom_action_test2.msi',
	           input: {files: ['CustomActionExe/hello_world.exe'],
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [ {file: 'hello_world.exe', exe_command: output[:before_inst_finalize]} ]},
			   post_installation: [:before_inst_finalize]},
	  test3: { msi: 'test/wixgem_custom_action_test3.msi',
	           input: {files: ['all_tests.rb'],
	                   binary_table: [{ id: 'binary_table', file: 'CustomActionExe/hello_world.exe' }],
                       custom_actions: [ {binary_key: 'binary_table', exe_command: output[:after_inst_initialize], after: 'InstallInitialize'  } ]},
		   post_installation: [:after_inst_initialize]},					   
	  test4: { msi: 'test/wixgem_custom_action_test4.msi',
	           input: {files: ['CustomActionExe/hello_world.exe'],
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [ {file: 'hello_world.exe', exe_command: output[:before_remove_files], before: 'RemoveFiles', condition: 'REMOVE' } ]},
			   post_uninstall: [:before_remove_files]},				   
	  test5: { msi: 'test/wixgem_custom_action_test5.msi',
	           input: {files: ['CustomActionExe/hello_world.exe'],
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [{file: 'hello_world.exe', exe_command: output[:before_inst_finalize]},
					                    {file: 'hello_world.exe', exe_command: output[:before_remove_files], before: 'RemoveFiles', condition: 'REMOVE' } ]},
			   post_uninstall: [:before_inst_finalize, :before_remove_files]},				   
	  test6: { msi: 'test/wixgem_custom_action_test6.msi',
	           input: {files: ['CustomActionExe/hello_world.exe'],
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [{property: 'execute_it', value: '"[SystemFolder]xcopy.exe" "[SystemFolder]write.exe" "C:\Development\wrk\gitub\wixgem\tests\test"',  
					                     execute: 'immediate',  condition: 'NOT Installed AND NOT REMOVE'},
										{id: 'execute_it', binary_key: 'WixCA', dll_entry: 'CAQuietExec', 
					                     execute: 'deferred',
										 condition: 'NOT Installed AND NOT REMOVE'} ]},
			   post_uninstall: [:quiet_execution_ca]}				   
    }
	
    test_arguments.each do |test_id, test_data| 
	  File.delete(test_data[:msi]) if(File.exists?(test_data[:msi]))
	  output.each { |k,f| File.delete(f) if(File.exists?(f)) }
	
      Wixgem::Wix.make_installation(test_data[:msi], test_data[:input])
	  assert(File.exists?(test_data[:msi]), "Test #{test_id}: Should have created an installation file: #{test_data[:msi]}") 
    
	  install_msi(test_data[:msi], test_data[:input]) do |install_path| 
	    if(test_data.key?(:post_installation))
		  test_data[:post_installation].each do |key|
	        assert(File.exists?(output[key]), "Test #{test_id}: Custom action should have created file: #{output[key]}") 
		  end
		end
	  end
	    
      if(test_data.key?(:post_uninstall))
	    test_data[:post_uninstall].each do |key|
	      assert(File.exists?(output[key]), "Test #{test_id}: Custom action should have created file: #{output[key]}") 
		end
      end
	end
  end  
  def test_merge_module
    dir = File.absolute_path(File.dirname(__FILE__))
    output = { 
	  before_inst_finalize_merge: "#{dir}/test/before_inst_finalize_merge.txt",
	  before_remove_files_merge: "#{dir}/test/before_remove_files_merge.txt",
	  before_inst_finalize_install: "#{dir}/test/before_inst_finalize_install.txt",
	  before_remove_files_install: "#{dir}/test/before_inst_finalize_install.txt"
	}

    test_arguments = {
	  test1: { msm: 'test/wixgem_custom_action_test_m1.msm',
	           msi: 'test/wixgem_custom_action_test_m1.msi',
	           msm_input: {files: ['CustomActionExe/hello_world.exe'],
			           debug: true,
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [{file: 'hello_world.exe', exe_command: output[:before_inst_finalize_merge]},
					                    {file: 'hello_world.exe', exe_command: output[:before_remove_files_merge], before: 'RemoveFiles', condition: 'REMOVE' } ]},
	           msi_input: ['test/wixgem_custom_action_test_m1.msm'],
			   post_uninstall: [:before_inst_finalize_merge, :before_remove_files_merge]},				   
	  test2: { msm: 'test/wixgem_custom_action_test_m2.msm',
	           msi: 'test/wixgem_custom_action_test_m2.msi',
	           msm_input: {files: ['CustomActionExe/hello_world.exe'],
			           debug: true,
                       modify_file_paths: {/CustomActionExe\// => ''},
                       custom_actions: [{file: 'hello_world.exe', exe_command: output[:before_inst_finalize_merge]},
					                    {file: 'hello_world.exe', exe_command: output[:before_remove_files_merge], before: 'RemoveFiles', condition: 'REMOVE' } ]},
	           msi_input: {files: ['test/wixgem_custom_action_test_m2.msm'],
			           debug: true,
	                   binary_table: [{ id: 'binary_table', file: 'CustomActionExe/hello_world.exe' }],
		               custom_actions: [ {binary_key: 'binary_table', exe_command: output[:before_inst_finalize_install], before: 'InstallFinalize', condition: 'NOT Installed AND NOT REMOVE'},
					                     {binary_key: 'binary_table', exe_command: output[:before_remove_files_install], before: 'RemoveFiles', condition: 'REMOVE' } ]},
			   post_uninstall: [:before_inst_finalize_merge, :before_remove_files_merge, :before_inst_finalize_install, :before_remove_files_install]},				   
    }
	
    test_arguments.each do |test_id, test_data| 
	  File.delete(test_data[:msi]) if(File.exists?(test_data[:msi]))
	  output.each { |k,f| File.delete(f) if(File.exists?(f)) }
	
      Wixgem::Wix.make_mergemodule(test_data[:msm], test_data[:msm_input])
      Wixgem::Wix.make_installation(test_data[:msi], test_data[:msi_input])
	  assert(File.exists?(test_data[:msi]), "Should have created an installation file: #{test_data[:msi]}") 
    
	  install_msi(test_data[:msi], test_data[:input]) do |install_path| 
	    if(test_data.key?(:post_installation))
		  test_data[:post_installation].each do |key|
	        assert(File.exists?(output[key]), "Custom action should have created file: #{output[key]}") 
		  end
		end
	  end
	    
      if(test_data.key?(:post_uninstall))
	    test_data[:post_uninstall].each do |key|
	      assert(File.exists?(output[key]), "Custom action should have created file: #{output[key]}") 
		end
      end
	end
  end  
end
