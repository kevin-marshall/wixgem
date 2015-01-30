require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_files_exist.rb'

describe 'Wixgem' do
  describe 'Installation' do
    test_arguments = {
      test0: ['wixgem_install_test1.msi', ['rakefile.rb']],
      test1: ['test/wixgem_install_test1.msi', ['rakefile.rb']],
	  test2: ['test/wixgem_install_test2.msi', {manufacturer: 'musco', files: ['Gemfile']}], 
	  test3: ['test/wixgem_install_test3.msi', ['rakefile.rb', 'Gemfile']],
	  test4: ['test/wixgem_install_test4.msi', {version: '1.1.2.3', files: ['Gemfile']}],
	  test5: ['test/wixgem_install_test5.msi', {product_code: '{4528ae5a-c7fa-40a6-a70e-ac8135f1114c}', files: ['Gemfile']}],
	  test6: ['test/wixgem_install_test6.msi', {upgrade_code: '{1d5df00a-c18d-4897-95e6-8c936dd19647}', files: ['Gemfile']}],
	  test7: ['test/wixgem_install_test7.msi', {product_name: 'test_productname', files: ['Gemfile']}],
	  test9: ['test/wixgem_install_heat_problem_dll.msi', {debug: true, suppress_registry_harvesting: true, files: ['test_files/heat_com_reg_problem/zlib.dll']}],
	  test8: ['test/wixgem_install_test8.msi', {modify_file_paths: {/\Atest_files\// => ''}, suppress_registry_harvesting: true, files: Dir.glob("test_files/**/*")}]
    }
	
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))
	
	  it "should create an installation file using: #{value[0]}" do
        Wixgem::Wix.make_installation(value[0], value[1])
	    expect(File.exists?(value[0])).to be(true)	  
	  end
    
	  it "should install and uninstall: #{value[0]}" do
	    execute = "test_files_exist('#{value[0]}', #{value[1]})"
	    execute = value[2] if(value.length == 3)
	    test_install(key, value[0], value[1], execute) 
	  end	  
	}
    end
  
  describe 'Packaging exceptions' do 
    exception_test_arguments = [
      {id: 'test1', msi_file: 'test/wixgem_install_test1.msi', input: nil },
      {id: 'test2', msi_file: 'test/wixgem_install_test2.msi', input: [] },
      {id: 'test3', msi_file: 'test/wixgem_install_test3.msi', input: ['does_not_exist.txt'] },
	  {id: 'test4', msi_file: 'test/wixgem_install_test3.msi', input: ["#{__FILE__}"], error_msg: "Invalid relative installation path: #{__FILE__}" }	  
    ]
  
    exception_test_arguments.each { |test|
	  it "#{test[:id]} should raise an exception" do
	    if(test.has_key?(:error_msg))
			expect { Wixgem::Wix.make_installation(test[:msi_file], test[:input]) }.to raise_error(/#{test[:error_msg]}/)
		else
			expect { Wixgem::Wix.make_installation(test[:msi_file], test[:input]) }.to raise_error
		end
	  end
    }
  end	
    
  describe 'including vb6 files' do 
	it "the wix's heat command should contain the -svb6 flag" do
      Wixgem::Wix.make_installation('test/wixgem_install_vb6_files.msi', {debug: true, has_vb6_files: true, files: ['rakefile.rb']})
	  wix_cmd_text = File.read('test/wixgem_install_vb6_files.msi.log')
	  expect(wix_cmd_text.include?('-svb6')).to eq(true)
	end
  end	 
  
  describe 'installer version' do 
	it "the default installer version should be set to 450" do
      Wixgem::Wix.make_installation('test/wixgem_installer_version1.msi', {debug: true, files: ['rakefile.rb']})
	  wxs_text = File.read('test/wixgem_installer_version1.msi.wxs')
	  xml_doc = REXML::Document.new(wxs_text)
	  packages = REXML::XPath.match(xml_doc, '//Wix/Product/Package')
	  packages.each { |package| 
		expect(package.attributes['InstallerVersion'].to_i).to eq(450)
	  }
	end
	
	it "the installer version should be set to 200" do
      Wixgem::Wix.make_installation('test/wixgem_installer_version2.msi', {debug: true, installer_version: 2.0, files: ['rakefile.rb']})
	  wxs_text = File.read('test/wixgem_installer_version2.msi.wxs')
	  xml_doc = REXML::Document.new(wxs_text)
	  packages = REXML::XPath.match(xml_doc, '//Wix/Product/Package')
	  packages.each { |package| 
		expect(package.attributes['InstallerVersion'].to_i).to eq(200)
	  }
	end
  end	  

end