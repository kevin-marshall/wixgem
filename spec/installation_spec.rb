require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_files_exist.rb'

describe 'Wixgem' do
  #Wix.debug = true
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
	  test8: ['test/wixgem_install_test8.msi', {modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob("test_files/**/*")}]
    }
	
    test_arguments.each { |key, value| 
	  it "should create an installation file using: #{value[0]}" do
        Wix.make_installation(value[0], value[1])
	    expect(File.exists?(value[0])).to be(true)	  
	  end
    
	  it "should install and uninstall: #{value[0]}" do
	    execute = "test_files_exist('#{value[0]}', #{value[1]})"
	    execute = value[2] if(value.length == 3)
	    test_install(key, value[0], value[1], execute) 
	  end
    }

    test_arguments.each { |key, value| FileUtils.rm(value[0]) if(File.exists?(value[0])) }  
  end
  
  describe 'Packaging excptions' do 
    exception_test_arguments = {
      test1: ['test/wixgem_install_test1.msi', nil],
      test2: ['test/wixgem_install_test1.msi', []],
      test3: ['test/wixgem_install_test1.msi', ['does_not_exist.txt']]
    }
  
    exception_test_arguments.each { |key, value|
	  it "#{key} should raise an exception" do
	    expect { Wix.make_installation(value[0], value[1]) }.to raise_error
	  end
    }
  end	
    
  describe 'including vb6 files' do 
	it "the wix's heat command should contain the -svb6 flag" do
      Wix.make_installation('test/wixgem_install_vb6_files.msi', {debug: true, manufacturer: 'musco', has_vb6_files: true, files: ['rakefile.rb'], debug: true})
	  wix_cmd_text = File.read('test/wixgem_install_vb6_files.msi.log')
	  expect(wix_cmd_text.include?('-svb6')).to eq(true)
	end
  end	

end
