require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'

describe 'Merge Module' do    
  test_arguments = {
    test1: ['test/wixgem_merge_test1.msm', ['rakefile.rb']],
	test2: ['test/wixgem_merge_test2.msm', {files: ['Gemfile']}],
	test3: ['test/wixgem_merge_test3.msm', ['rakefile.rb', 'Gemfile']],
	test4: ['test/wixgem_merge_test5.msm', Dir.glob("test_files/**/*")]
  }
  
  test_arguments.each { |key, value| 
	it "should create merge module: #{value[0]}" do
	  Wix.make_mergemodule(value[0], value[1])
	  raise "#{key}: #{value[0]} does not exist" unless(File.exists?(value[0]))
	end
	
	install_file = value[0].gsub(/msm/) { |s| s = 'msi' }
	it "should be able to create an installation file using: #{value[0]}" do
      Wix.make_installation(install_file, ["#{value[0]}"])
	  
	  expect(File.exists?(install_file)).to be(true)
	  
	  File.delete(value[0])
	end
    
	it "should install and uninstall: #{install_file}" do
	  test_install(key, install_file, value[1]) 
	end
  }

  test_arguments.each { |key, value| FileUtils.rm(value[0]) if(File.exists?(value[0])) }
  
end
