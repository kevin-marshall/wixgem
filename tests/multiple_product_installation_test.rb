require 'minitest/autorun'
require_relative '../lib/wixgem.rb'
require 'WindowsInstaller.rb'
require_relative '../lib/file.rb'
require_relative '../lib/admin.rb'

class MultipleProductInstallation_test < MiniTest::Unit::TestCase
  def setup
    @installer = WindowsInstaller.new
	FileUtils.cp('../rakefile.rb', '.') unless(File.exists?('rakefile.rb'))
	FileUtils.cp('../Gemfile', '.') unless(File.exists?('Gemfile'))
  end
  def teardown
    File.delete('rakefile.rb')
    File.delete('Gemfile')
  end

  if(admin?)
  def test_side_by_side_installations
    product1='wixgem_multiple 1.0'
    product2='wixgem_multiple 1.1'
      
	product_name="wixgem_multiple 1.1"
	while(@installer.product_installed?(product_name))
	  @installer.uninstall_product(product_name)
	end
 
    assert(!@installer.product_installed?(product1), "product #{product1} should not be installed")
    assert(!@installer.product_installed?(product2), "product #{product2} should not be installed")

    Wixgem::Wix.make_installation("test/wixgem_multiple.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
    Wixgem::Wix.make_installation("test/wixgem_multiple.1.1.0.msi", {version: '1.1.0.0', product_name: product2, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

 	@installer.install_msi('test\\wixgem_multiple.1.0.0.msi')
    assert(@installer.product_installed?(product1), "The product should be installed")
	
	properties1 = @installer.installation_properties(product1)
	assert(properties1['VersionString'] == '1.0.0.0', "The version should be 1.0.0.0")

 	@installer.install_msi('test\\wixgem_multiple.1.1.0.msi')
	assert(@installer.product_installed?(product2))
	properties2 = @installer.installation_properties(product2)
	assert(properties2['VersionString'] == '1.1.0.0', "should install version 1.1.0.0")
	  
	assert(@installer.product_installed?(product1), "version 1.0.0 should still be installed")

	assert(properties1['ProductCode'] != properties2['ProductCode'], "product codes for version 1.0.0 and 1.0.0 should be different")

  	@installer.uninstall_product(product1)
	assert(!@installer.product_installed?(product1), "Should be able to uninstall both products")
	@installer.uninstall_product(product2) 
	assert(!@installer.product_installed?(product2), "Should be able to uninstall both products")
  end

  def test_remove_previous_version
    product1='wixgem_install 1.0'
    product2='wixgem_install 1.1'
	
    assert(!@installer.product_installed?(product1), "product #{product1} should not be installed")
    assert(!@installer.product_installed?(product2), "product #{product2} should not be installed")
	
	Wixgem::Wix.make_installation("test/wixgem_install.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
	Wixgem::Wix.make_installation("test/wixgem_install.1.1.0.msi", {version: '1.1.0.0', product_name: product2, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
	
	@installer.install_msi('test\\wixgem_install.1.0.0.msi')
	assert(@installer.product_installed?(product1), "should install version 1.0.0")

	@installer.install_msi('test\\wixgem_install.1.1.0.msi')
	assert(@installer.product_installed?(product2), "should install version 1.1.0")
	  
    assert(!@installer.product_installed?(product1), "#{product1} should have been uninstalled when #{product2} was installed")
	
  	@installer.uninstall_product(product2) 
  end
end
end

