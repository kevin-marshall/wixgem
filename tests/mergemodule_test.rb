require 'minitest/autorun'
require 'WindowsInstaller.rb'
#require 'win32ole'

require_relative '../lib/wixgem.rb'
require_relative 'install_msi'
require_relative 'test_files_exist.rb'
#require_relative 'test_file_attributes.rb'
require_relative 'assert_exception.rb'

class MergeModule_test < MiniTest::Unit::TestCase
  def setup
    @installer = WindowsInstaller.new
	FileUtils.cp('../rakefile.rb', 'rakefile.rb') unless(File.exists?('rakefile.rb'))
	FileUtils.cp('../Gemfile', 'Gemfile') unless(File.exists?('Gemfile'))
  end
  def teardown
    File.delete('rakefile.rb')
    File.delete('Gemfile')
  end
  
  def test_merge_module    
    test_arguments = {
      #test1: ['test/wixgem_merge_test1.msm', ['rakefile.rb']],
	  #test2: ['test/wixgem_merge_test2.msm', ['Gemfile']],
	  #test3: ['test/wixgem_merge_test3.msm', ['rakefile.rb', 'Gemfile']],
	  #test4: ['test/wixgem_merge_test4.msm', Dir.glob("test_files/9.0/*")],
	  test5: ['test/wixgem_merge_test5.msm', {debug: true, files: ['rakefile.rb', 'Gemfile'], requires_win10_crt: true, requires_netframework: 'NETFRAMEWORK35'}]	  
    }
  
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))

	  Wixgem::Wix.make_mergemodule(value[0], value[1])
	  assert(File.exists?(value[0]), "should create merge module: #{value[0]}")
	
	  install_file = value[0].gsub(/msm/) { |s| s = 'msi' }
      Wixgem::Wix.make_installation(install_file, {files: ["#{value[0]}"]}) # , debug: true})
	  
	  assert(File.exists?(install_file), "should be able to create an installation file using: #{value[0]}")
    
	  install_msi(install_file) { |install_dir| test_files_exist(install_file, value[1]) }
    }
  end  
  
  def packaging_mergemodule_exceptions 
    exception_test_arguments = [
      {
		file: 'test/wixgem_merge_test100.msm', 
		input: ['test/wixgem_merge_test1.msm', 'test/wixgem_merge_test1.msm'],
		msg: 'Wixgem exception: Merge modules can not be added to a merge module' 
	  }
    ]
  
    exception_test_arguments.each { |test|
	  assert_exception(Proc.new { Wixgem::Wix.make_installation(test[:file], test[:input]) }, test[:msg])
    }
  end	
  
  def test_multiple_merge_module 
    msi_file='test\\wixgem_multiple_merge_test1.msi'
    merge1='test\\wixgem_multiple_merge_test1.msm'
    merge2='test\\wixgem_multiple_merge_test2.msm'

	Wixgem::Wix.debug=true
    Wixgem::Wix.make_mergemodule(merge1, ['rakefile.rb'])
	assert(File.exists?(merge1), "should be able to create two merge modules")
    Wixgem::Wix.make_mergemodule(merge2, ['Gemfile'])
	assert(File.exists?(merge2), "should be able to create two merge modules")
		
    Wixgem::Wix.make_installation(msi_file, [merge1, merge2])
	assert(File.exists?(msi_file),"should be able to create an installation file using: #{msi_file}")
	
	install_msi(msi_file) do |install_dir|	    
	  assert(File.exists?("#{install_dir}/rakefile.rb"),"should install contents of merge module")
	  assert(File.exists?("#{install_dir}/Gemfile"),"should install contents of merge module")
	end
  end
end
