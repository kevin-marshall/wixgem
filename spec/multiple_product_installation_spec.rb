require 'rspec'
require './lib/wixgem.rb'
require './lib/WindowsInstaller.rb'
require './spec/wixpath.rb'
require './admin.rb'

if(admin?)
describe 'Wixgem' do
  describe 'Side by side installations' do
    product1='wixgem_multiple 1.0'
    product2='wixgem_multiple 1.1'
      
    it "product #{product1} should not be installed" do
      expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(false)
	end

    it "product #{product2} should not be installed" do
      expect(Wixgem::WindowsInstaller.product_name_installed?(product2)).to be(false)
	end

    it "should be able to create installation packages #{product1} and #{product2}" do
	  Wixgem::Wix.make_installation("test/wixgem_multiple.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
      Wixgem::Wix.make_installation("test/wixgem_multiple.1.1.0.msi", {version: '1.1.0.0', product_name: product2, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
	end

    it "should install version 1.0.0" do
	  Wixgem::WindowsInstaller.install('test\\wixgem_multiple.1.0.0.msi')
      expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(true)
	  expect(Wixgem::WindowsInstaller.version_from_product_name(product1)).to eq('1.0.0.0')
	end

    it "should install version 1.1.0" do
	  Wixgem::WindowsInstaller.install('test\\wixgem_multiple.1.1.0.msi')
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product2)).to be(true)
	  expect(Wixgem::WindowsInstaller.version_from_product_name(product2)).to eq('1.1.0.0')
	end
	  
	it "version 1.0.0 should still be installed" do
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(true)
	end

	it "product codes for version 1.0.0 and 1.0.0 should be different" do
	  product_code1= Wixgem::WindowsInstaller.product_code_from_product_name(product1)
	  product_code2= Wixgem::WindowsInstaller.product_code_from_product_name(product2)
	  expect(product_code1).not_to eq(product_code2)
	end

	it "Should be able to uninstall both products" do
  	  Wixgem::WindowsInstaller.uninstall_product_name(product1)
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to eq(false)
	  Wixgem::WindowsInstaller.uninstall_product_name(product2) 
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product2)).to eq(false)
	end
  end

  describe 'test remove previous version' do
    product1='wixgem_install 1.0'
    product2='wixgem_install 1.1'
	
    it "product #{product1} should not be installed" do
      expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(false)
	end

    it "product #{product2} should not be installed" do
      expect(Wixgem::WindowsInstaller.product_name_installed?(product2)).to be(false)
	end
	
    it "should be able to create installation packages #{product1} and #{product2}" do
		Wixgem::Wix.make_installation("test/wixgem_install.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
		Wixgem::Wix.make_installation("test/wixgem_install.1.1.0.msi", {version: '1.1.0.0', product_name: product2, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
	end
	
    it "should install version 1.0.0" do
	  Wixgem::WindowsInstaller.install('test\\wixgem_install.1.0.0.msi')
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(true)
	end

    it "should install version 1.1.0" do
	  Wixgem::WindowsInstaller.install('test\\wixgem_install.1.1.0.msi')
	  expect(Wixgem::WindowsInstaller.product_name_installed?(product2)).to be(true)
	end
	  
	it "#{product1} should have been uninstalled when #{product2} was installed" do
      expect(Wixgem::WindowsInstaller.product_name_installed?(product1)).to be(false)
	end
	
	it "should be able to uninstall #{product2}" do
  	  Wixgem::WindowsInstaller.uninstall_product_name(product2) 
	end
  end
end
end