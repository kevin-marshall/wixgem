require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/WindowsInstaller.rb'
require './admin.rb'

if(admin?)
describe 'Wixgem' do
  describe 'Side by side installations' do
    product1='wixgem_multiple 1.0'
    product2='wixgem_multiple 1.1'
      
	Wixgem::Wix.make_installation("test/wixgem_multiple.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
    Wixgem::Wix.make_installation("test/wixgem_multiple.1.1.0.msi", {version: '1.1.0.0', product_name: product2, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

    it "should install version 1.0.0" do
	  WindowsInstaller.install('test\\wixgem_multiple.1.0.0.msi')
      expect(WindowsInstaller.installed?(product1)).to be(true)
	  expect(WindowsInstaller.version(product1)).to eq('1.0.0.0')
	end

    it "should install version 1.1.0" do
	  WindowsInstaller.install('test\\wixgem_multiple.1.1.0.msi')
	  expect(WindowsInstaller.installed?(product2)).to be(true)
	  expect(WindowsInstaller.version(product2)).to eq('1.1.0.0')
	end
	  
	it "version 1.0.0 should still be installed" do
	  expect(WindowsInstaller.installed?(product1)).to be(true)
	end

	it "product codes for version 1.0.0 and 1.0.0 should be different" do
	  expect(WindowsInstaller.product_code(product1)).not_to eq(WindowsInstaller.product_code(product2))
	end

	it "Should be able to uninstall both products" do
  	  WindowsInstaller.uninstall(product1)
	  WindowsInstaller.uninstall(product2) 
	end
  end

  describe 'remove previous version' do
    product1='wixgem_install 1.0'
    product2='wixgem_install 1.1'
    Wixgem::Wix.make_installation("test/wixgem_install.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
    Wixgem::Wix.make_installation("test/wixgem_install.1.1.0.msi", {version: '1.1.0.0', product_name: product2, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

    it "should install version 1.0.0" do
	  WindowsInstaller.install('test\\wixgem_install.1.0.0.msi')
	  expect(WindowsInstaller.installed?(product1)).to be(true)
	end

    it "should install version 1.1.0" do
	  WindowsInstaller.install('test\\wixgem_install.1.1.0.msi')
	  expect(WindowsInstaller.installed?(product2)).to be(true)
	end
	  
	it "the version 1.0.0 should have been uninstalled" do
      expect(WindowsInstaller.installed?(product1)).to be(false)
	end
	
	it "should be able to uninstall #{product2}" do
  	  WindowsInstaller.uninstall(product2) 
	end
  end
end
end