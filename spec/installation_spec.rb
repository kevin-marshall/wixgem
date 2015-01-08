require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'

describe 'Installation' do    
  test_arguments = {
    test1: ['test/wixgem_install_test1.msi', ['rakefile.rb']],
	test2: ['test/wixgem_install_test2.msi', {manufacturer: 'musco', files: ['Gemfile']}], 
	test3: ['test/wixgem_install_test3.msi', ['rakefile.rb', 'Gemfile']],
	test4: ['test/wixgem_install_test5.msi', {version: '1.1.2.3', files: ['Gemfile']}],
	test5: ['test/wixgem_install_test6.msi', {product_code: '{4528ae5a-c7fa-40a6-a70e-ac8135f1114c}', files: ['Gemfile']}],
	test6: ['test/wixgem_install_test7.msi', {product_name: 'test_productname', files: ['Gemfile']}]
  }

  test_arguments.each { |key, value| 
	it "should create an installation file using: #{value[0]}" do
      Wix.make_installation(value[0], value[1])
	  expect(File.exists?(value[0])).to be(true)	  
	end
    
	it "should install and uninstall: #{value[0]}" do
	  test_install(key, value[0], value[1]) 
	end
  }

  test_arguments.each { |key, value| FileUtils.rm(value[0]) if(File.exists?(value[0])) }  
 
  exception_test_arguments = {
    test1: ['test/wixgem_install_test1.msi', nil],
    test1: ['test/wixgem_install_test1.msi', []],
    test2: ['test/wixgem_install_test1.msi', ['does_not_exist.txt']]
  }
  
  exception_test_arguments.each { |key, value|
	it "should raise an exception" do
	  expect { Wix.make_installation(value[0], value[1]) }.to raise_error
	end
  }  
end
