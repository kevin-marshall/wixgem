require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/execute.rb'
require './admin.rb'

Wix.debug=true

describe 'Wixgem' do
  describe 'Merge Module' do    
    test_arguments = {
      test1: ['test/wixgem_merge_test1.msm', ['rakefile.rb']],
	  test2: ['test/wixgem_merge_test2.msm', {files: ['Gemfile']}],
	  test3: ['test/wixgem_merge_test3.msm', ['rakefile.rb', 'Gemfile']],
	  test4: ['test/wixgem_merge_test4.msm', Dir.glob("test_files/**/*")],
	  test5: ['test/wixgem_merge_test5.msm', {debug: true, files: Dir.glob("test_files/**/*")}]
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
	  end 
    
	  it "should install and uninstall: #{install_file}" do
	    test_install(key, install_file, value[1]) 
	  end
	  
	  if(key == 'test5')
	    puts "HERE"
	    it "should produce the debug files" do
	      expect(File.exists?("#{key}.wxs")).to be(true)
	      expect(File.exists?("#{key}.wix_cmds.txt")).to be(true)
	      expect(File.exists?("#{key}_paths.txt")).to be(true)
		end
	  end
    }
  end  
  
  if(admin?)
    describe 'Multiple merge Module' do 
      msi_file='test\\wixgem_multiple_merge_test1.msi'
      merge1='test\\wixgem_multiple_merge_test1.msm'
      merge2='test\\wixgem_multiple_merge_test2.msm'
      it "should be able to create two merge modules" do  
        Wix.make_mergemodule(merge1, ['rakefile.rb'])
	    expect(File.exists?(merge1)).to be(true)
        Wix.make_mergemodule(merge2, ['Gemfile'])
	    expect(File.exists?(merge2)).to be(true)
      end 
		
      it "should be able to create an installation file using: #{msi_file}" do
        Wix.make_installation(msi_file, [merge1, merge2])
	    expect(File.exists?(msi_file)).to be(true)
      end 
	
      it "should install contents of merge module" do
	    begin
	      execute("msiexec.exe /i #{msi_file}")
		
		  install_dir = "C:/Program Files (x86)/#{File.basename(msi_file, '.msi')}"
	      expect(File.exists?("#{install_dir}/rakefile.rb")).to be(true)
	      expect(File.exists?("#{install_dir}/Gemfile")).to be(true)
	    ensure
	      execute("msiexec.exe /quiet /x #{msi_file}")
	    end
      end 
	end
  end
end
