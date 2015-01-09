require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/test_install.rb'
require './spec/test_files_exist.rb'
require 'json'

describe 'Wixgem' do
#  describe 'Side by side installations' do
#    product_name='wixgem_installation'
#    begin
#      Wix.make_installation("test/#{product_name}.1.0.0.msi", {version: '1.0.0.0', product_name: product_name, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
#      Wix.make_installation("test/#{product_name}.1.1.0.msi", {version: '1.1.0.0', product_name: product_name, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
#
#	  product_code_1_0 = ''
#      it "should install version 1.0.0" do
#	    execute("msiexec.exe /i test\\wixgem_install_1.0.0.msi")
#		expect(WindowsInstaller.installed?(product_name)).to be(true)
#		expect(WindowsInstaller.version?(product_name)).to eq('1.0.0.0')

#		product_code_1_0 = WindowsInstaller.product_code?(product_name)
#	  end

#	  product_code_1_1 = ''
#      it "should install version 1.1.0" do
#	    execute("msiexec.exe /i test\\wixgem_install_1.0.1.msi")
#		expect(WindowsInstaller.installed?(product_name)).to be(true)
#		expect(WindowsInstaller.version?(product_name)).to eq('1.0.1.0')

#		product_code_1_1 = WindowsInstaller.product_code?(product_name)
#	  end
	  
#	  it "version 1.0.0 should still be installed" do
#		expect(WindowsInstaller.product_code_installed?(product_code_1_0)).to be(true)
#	  end

#	  it "product codes for version 1.0.0 and 1.0.0 should be different" do
#		expect(product_code_1_0_0).not_to eq(product_code_1_1_0)
#	  end
#	ensure
#  	  while(WindowsInstaller.installed?(product_name))
#	    execute("msiexec.exe /quiet /x #{WindowsInstaller.product_code?(product_name)}")
#	  end
#	  raise "Failed to uninstall product #{product_name}" if(WindowsInstaller.installed?(product_name))
#	end
#  end

#  describe 'remove previous version' do
#    product_name='wixgem_installation'
#    begin
#      Wix.make_installation("test/#{product_name}.1.0.0.msi", {version: '1.0.0.0', product_name: product_name, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
#      Wix.make_installation("test/#{product_name}.1.1.0.msi", {version: '1.1.0.0', product_name: product_name, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

#	  product_code_1_0 = ''
#      it "should install version 1.0.0" do
#	    execute("msiexec.exe /i test\\wixgem_install_1.0.0.msi")
#		expect(WindowsInstaller.installed?(product_name)).to be(true)

#		product_code_1_0 = WindowsInstaller.product_code?(product_name)
#	  end

#	  product_code_1_1 = ''
#      it "should install version 1.1.0" do
#	    execute("msiexec.exe /i test\\wixgem_install_1.1.0.msi")
#		expect(WindowsInstaller.installed?(product_name)).to be(true)
#
#		product_code_1_1 = WindowsInstaller.product_code?(product_name)
#	  end
	  
#	  it "the version 1.0.0 should have been uninstalled" do
#		expect(WindowsInstaller.product_code_installed?(product_code_1_0_0)).to be(false)
#	  end
#	ensure
 # 	  while(WindowsInstaller.installed?(product_name))
#	    execute("msiexec.exe /quiet /x #{WindowsInstaller.product_code?(product_name)}")
#	  end
#	  raise "Failed to uninstall product #{product_name}" if(WindowsInstaller.installed?(product_name))
#	end
#  end
end
