require 'minitest/autorun'
require_relative '../lib/wixgem.rb'
require_relative 'wixpath.rb'
require_relative '../lib/WindowsInstaller.rb'
require_relative '../lib/file.rb'
require_relative '../lib/admin.rb'

class MultipleProductInstallation_test < MiniTest::Unit::TestCase
  def setup
	FileUtils.cp('../rakefile.rb', '.') unless(File.exists?('rakefile.rb'))
	FileUtils.cp('../Gemfile', '.') unless(File.exists?('Gemfile'))
  end
  def teardown
    File.delete('rakefile.rb')
    File.delete('Gemfile')
  end

  if(admin?)
  def side_by_side_installations
    product1='wixgem_multiple 1.0'
    product2='wixgem_multiple 1.1'
      
	product_name="wixgem_multiple 1.1"
	while(Wixgem::WindowsInstaller.product_name_installed?(product_name))
	  Wixgem::WindowsInstaller.uninstall_product_name(product_name)
	end
 
    assert(!Wixgem::WindowsInstaller.product_name_installed?(product1), "product #{product1} should not be installed")
    assert(!Wixgem::WindowsInstaller.product_name_installed?(product2), "product #{product2} should not be installed")

    Wixgem::Wix.make_installation("test/wixgem_multiple.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
    Wixgem::Wix.make_installation("test/wixgem_multiple.1.1.0.msi", {version: '1.1.0.0', product_name: product2, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

 	Wixgem::WindowsInstaller.install('test\\wixgem_multiple.1.0.0.msi')
    assert(Wixgem::WindowsInstaller.product_name_installed?(product1), "The product should be installed")
	assert(Wixgem::WindowsInstaller.version_from_product_name(product1) == '1.0.0.0', "The version should be 1.0.0.0")

 	Wixgem::WindowsInstaller.install('test\\wixgem_multiple.1.1.0.msi')
	assert(Wixgem::WindowsInstaller.product_name_installed?(product2)).to be(true)
	assert(Wixgem::WindowsInstaller.version_from_product_name(product2) == '1.1.0.0', "should install version 1.1.0.0")
	  
	assert(Wixgem::WindowsInstaller.product_name_installed?(product1), "version 1.0.0 should still be installed")

	product_code1= Wixgem::WindowsInstaller.product_code_from_product_name(product1)
	product_code2= Wixgem::WindowsInstaller.product_code_from_product_name(product2)
	assert(product_code1 != product_code2, "product codes for version 1.0.0 and 1.0.0 should be different")

  	Wixgem::WindowsInstaller.uninstall_product_name(product1)
	assert(!Wixgem::WindowsInstaller.product_name_installed?(product1), "Should be able to uninstall both products")
	Wixgem::WindowsInstaller.uninstall_product_name(product2) 
	assert(!Wixgem::WindowsInstaller.product_name_installed?(product2), "Should be able to uninstall both products")
  end

  def test_remove_previous_version
    product1='wixgem_install 1.0'
    product2='wixgem_install 1.1'
	
    assert(!Wixgem::WindowsInstaller.product_name_installed?(product1), "product #{product1} should not be installed")

    assert(!Wixgem::WindowsInstaller.product_name_installed?(product2), "product #{product2} should not be installed")
	
	Wixgem::Wix.make_installation("test/wixgem_install.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
	Wixgem::Wix.make_installation("test/wixgem_install.1.1.0.msi", {version: '1.1.0.0', product_name: product2, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
	
	Wixgem::WindowsInstaller.install('test\\wixgem_install.1.0.0.msi')
	assert(Wixgem::WindowsInstaller.product_name_installed?(product1), "should install version 1.0.0")

	Wixgem::WindowsInstaller.install('test\\wixgem_install.1.1.0.msi')
	assert(Wixgem::WindowsInstaller.product_name_installed?(product2), "should install version 1.1.0")
	  
    assert(!Wixgem::WindowsInstaller.product_name_installed?(product1), "#{product1} should have been uninstalled when #{product2} was installed")
	
  	Wixgem::WindowsInstaller.uninstall_product_name(product2) 
  end
  end
end

