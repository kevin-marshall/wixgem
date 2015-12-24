require 'minitest/autorun'
require 'WindowsInstaller'
require 'win32ole'

require_relative '../lib/wixgem.rb'
require_relative 'test_install.rb'
require_relative 'test_files_exist.rb'
require_relative 'test_file_attributes.rb'
require_relative 'assert_exception.rb'
require_relative 'install_msi'

class Installation_test < MiniTest::Unit::TestCase
  def setup
	@installer = WindowsInstaller.new
	FileUtils.cp('../rakefile.rb', 'rakefile.rb') unless(File.exists?('rakefile.rb'))
	FileUtils.cp('../Gemfile', 'Gemfile') unless(File.exists?('Gemfile'))
  end
  def teardown
    File.delete('rakefile.rb')
    File.delete('Gemfile')
  end
  
  def test_installation
    test_arguments = {
      test0: ['wixgem_install_test1.msi', ['rakefile.rb']],
      test1: ['test/wixgem_install_test1.msi', ['rakefile.rb']],
	  test2: ['test/wixgem_install_test2.msi', {manufacturer: 'musco', files: ['Gemfile']}], 
	  test3: ['test/wixgem_install_test3.msi', ['rakefile.rb', 'Gemfile']],
	  test4: ['test/wixgem_install_test4.msi', {version: '1.1.2.3', files: ['Gemfile']}],
	  test5: ['test/wixgem_install_test5.msi', {product_code: '{4528ae5a-c7fa-40a6-a70e-ac8135f1114c}', files: ['Gemfile']}],
	  test6: ['test/wixgem_install_test6.msi', {upgrade_code: '{1d5df00a-c18d-4897-95e6-8c936dd19647}', files: ['Gemfile']}],
	  test7: ['test/wixgem_install_test7.msi', {product_name: 'test_productname', files: ['Gemfile']}],
	  test8: ['test/wixgem_install_heat_problem_dll.msi', {debug: true, suppress_registry_harvesting: true, files: ['test_files/heat_com_reg_problem/zlib.dll']}],
	  test9: ['test/wixgem_install_test9.msi', {debug: true, modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob('test_files/**/*'), suppress_registry_harvesting: true}],
	  test10: ['test/wixgem_install_test10.msi', {debug: true, modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob('test_files/**/*'), ignore_files: ['test_files/heat_com_reg_problem/zlib.dll']}],
    }
	
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))
	
      Wixgem::Wix.make_installation(value[0], value[1])
	  assert(File.exists?(value[0]), "Should have created an installation file: #{value[0]}") 
    
	  test_install(key, value[0], value[1], "test_files_exist('#{value[0]}', #{value[1]})") 
	}
  end
  def test_packaging_exceptions
    absolute_path = File.absolute_path(__FILE__)
    exception_test_arguments = [
     {id: 'test1', msi_file: 'test/wixgem_install_exception_test1.msi', input: nil },
     {id: 'test2', msi_file: 'test/wixgem_install_exception_test2.msi', input: [] },
     {id: 'test3', msi_file: 'test/wixgem_install_exception_test3.msi', input: ['does_not_exist.txt'] },
	 {id: 'test4', msi_file: 'test/wixgem_install_exception_test4.msi', input: [absolute_path], error_msg: "Invalid absolute installation path: #{absolute_path}" },	  
	 {id: 'test5', msi_file: 'test/wixgem_install_exception_test5.msi', input: { debug: true, files: [absolute_path], ignore_files: [absolute_path]}},	  
	 {id: 'test6', msi_file: 'test/wixgem_install_exception_test6.msi', input: { files: Dir.glob('test_files/**/*'), ignore_files: Dir.glob('test_files/**/*')}, error_msg: "At least one file is required" }	  
    ]
  
    exception_test_arguments.each { |test|
	  if(test.has_key?(:error_msg))
	    assert_exception( Proc.new { Wixgem::Wix.make_installation(test[:msi_file], test[:input]) }, test[:error_msg])
	  else
	    assert_exception( Proc.new { Wixgem::Wix.make_installation(test[:msi_file], test[:input]) }, "#{test[:id]} should raise an exception" )
	  end
    }
  end	
  
  def test_including_vb6_files
    Wixgem::Wix.make_installation('test/wixgem_install_vb6_files.msi', {debug: true, has_vb6_files: true, files: ['rakefile.rb']})
	wix_cmd_text = File.read('test/wixgem_install_vb6_files.msi.log')
	assert(wix_cmd_text.include?('-svb6'), "the wix's heat command should contain the -svb6 flag")
  end	 
  
  def test_installer_version
	Wixgem::Wix.make_installation('test/wixgem_installer_version1.msi', {debug: true, files: ['rakefile.rb']})
    wxs_text = File.read('test/wixgem_installer_version1.msi.wxs')
	xml_doc = REXML::Document.new(wxs_text)
	packages = REXML::XPath.match(xml_doc, '//Wix/Product/Package')
	packages.each { |package| assert(package.attributes['InstallerVersion'].to_i == 450, "the default installer version should be set to 450") }
	      
	Wixgem::Wix.make_installation('test/wixgem_installer_version2.msi', {debug: true, installer_version: 2.0, files: ['rakefile.rb']})
	wxs_text = File.read('test/wixgem_installer_version2.msi.wxs')
	xml_doc = REXML::Document.new(wxs_text)
    packages = REXML::XPath.match(xml_doc, '//Wix/Product/Package')
	packages.each { |package| assert(package.attributes['InstallerVersion'].to_i == 200) }
  end
  def test_remove_previous_version
    install_1_0 = 'test/wixgem_remove_previous_1.0.msi'
	install_1_1 = 'test/wixgem_remove_previous_1.1.msi'
	files=['rakefile.rb']
	
	Wixgem::Wix.make_installation(install_1_0, 
	                              {files: files,
								   debug: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.0.0.0'})
  
	Wixgem::Wix.make_installation(install_1_1, 
	                              {files: files,
								   debug: true,
								   remove_existing_products: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.1.0.0'})
								   
	installer = WindowsInstaller.new
	assert(!installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_0)
	assert(installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_1)
	assert(installer.msi_installed?(install_1_1))
	assert(!installer.msi_installed?(install_1_0),"#{install_1_0} should have been uninstalled during the installation of #{install_1_1}")
	installer.uninstall_msi(install_1_1)
	assert(!installer.msi_installed?(install_1_1),"#{install_1_1} should have been uninstalled")
  end

  def test_remove_previous_version
    install_1_0 = 'test/wixgem_remove_previous_1.0.msi'
	install_1_1 = 'test/wixgem_remove_previous_1.1.msi'
	files=['rakefile.rb']
	
	Wixgem::Wix.make_installation(install_1_0, 
	                              {files: files,
								   debug: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.0.0.0'})
  
	Wixgem::Wix.make_installation(install_1_1, 
	                              {files: files,
								   debug: true,
								   remove_existing_products: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.1.0.0'})
								   
	installer = WindowsInstaller.new
	assert(!installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_0)
	assert(installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_1)
	assert(installer.msi_installed?(install_1_1))
	assert(!installer.msi_installed?(install_1_0),"#{install_1_0} should have been uninstalled during the installation of #{install_1_1}")
	installer.uninstall_msi(install_1_1)
	assert(!installer.msi_installed?(install_1_1),"#{install_1_1} should have been uninstalled")
  end
  def test_remove_previous_version1
    install_1_0 = 'test/wixgem_remove_previous_1.0.0.0.msi'
	install_1_1 = 'test/wixgem_remove_previous_1.0.0.1.msi'
	files=['rakefile.rb']
	
	Wixgem::Wix.make_installation(install_1_0, 
	                              {files: files,
								   debug: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.0.0.0'})
  
	Wixgem::Wix.make_installation(install_1_1, 
	                              {files: files,
								   debug: true,
								   remove_existing_products: true,
								   upgrade_code: '{1dc40b00-51f8-4ebc-b5ea-28b3a86bc735}',
								   version: '1.0.0.1'})
								   
	installer = WindowsInstaller.new
	assert(!installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_0)
	assert(installer.msi_installed?(install_1_0))
	installer.install_msi(install_1_1)
	assert(installer.msi_installed?(install_1_1))
	assert(!installer.msi_installed?(install_1_0),"#{install_1_0} should have been uninstalled during the installation of #{install_1_1}")
	installer.uninstall_msi(install_1_1)
	assert(!installer.msi_installed?(install_1_1),"#{install_1_1} should have been uninstalled")
  end
  
  #def test_custom_action
  #  install_file='test/wixgem_install_custom_action.msi'
	#files = ['CustomActionExe/hello_world.exe']
	#Wixgem::Wix.make_installation(install_file, 
	#                              {files: files,
	#							   #install_priviledges: 'elevated',
	#							   debug: true,
	#							   modify_file_paths: {/CustomActionExe\// => ''},
	#							   custom_actions: [ {file: 'hello_world.exe', condition: 'NOT Installed AND NOT REMOVE' } ]} )
	#
	#
	#install_msi(install_file) do |path|
	#  file="#{path}/hello_world.txt"
	#  assert(File.exists?(file), "If the custom action executed then #{file} should exist" )
	#end								   
 # end
end
