require 'rspec'
require './admin.rb'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_file_attributes.rb'

require 'rake'
require 'dev'

describe 'Wixgem' do
  describe 'test file attributes' do
    test_arguments = {
	  test100: ['test/wixgem_read_only_test.msi', {modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob('test_files/*')}],
    }
	
    test_arguments.each { |key, value| 
	  File.delete(value[0]) if(File.exists?(value[0]))
	
	  it "should create an installation file using: #{value[0]}" do
        Wixgem::Wix.make_installation(value[0], value[1])
	    expect(File.exists?(value[0])).to be(true)	  
	  end
   
      if(admin?)
	    it "should install and uninstall: #{value[0]}" do
	      test_install(key, value[0], value[1], "test_file_attributes('#{value[0]}', #{value[1]})") 
	    end
      end		
	}
  end  

  describe 'test file attributes' do
  files = Rake::FileList.new
  files.include('/Development/wrk/Musco.Cpp/lightworks.commandline/trunk/vc12/bin/Release/*.{dll,exe}',
                '/Development/wrk/Musco.Cpp/lightworks.commandline/trunk/library/**/*')
  Wixgem::Wix.install_path = "#{Environment.dev_root}/dep/OpenSource/WixToolset/3.9"
  Wixgem::Wix.make_installation("test/lightworks.commandline 1.0.msi",  
		  {debug: true, manufacturer: 'Musco', product_name: 'Lightworks commandline 1.0', 
		    version: "1.0.0.0", 
            upgrade_code: '{ec55f38b-d8b4-459d-ab81-bb970e44c631}', 
		    files: files,
			modify_file_paths: {/vc12\/bin\/Release/ => 'bin'}})  
  end  
end