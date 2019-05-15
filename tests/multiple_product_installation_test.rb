require 'minitest/autorun'

require 'WindowsInstaller.rb'

require_relative '../lib/wixgem.rb'
require_relative '../lib/file.rb'
require_relative 'test_methods/install_msi.rb'

class MultipleProductInstallation_test < Minitest::Test
  def setup
	  FileUtils.cp('../rakefile.rb', '.') unless(File.exists?('rakefile.rb'))
	  FileUtils.cp('../Gemfile', '.') unless(File.exists?('Gemfile'))
  end
  def teardown
    File.delete('rakefile.rb')
    File.delete('Gemfile')
    sleep(0.5)
  end

  def test_side_by_side_installations
    product1='wixgem_multiple 1.0'
    product2='wixgem_multiple 1.1'
      
	  installer = WindowsInstaller.new
	  product_name="wixgem_multiple 1.1" 
    assert(!installer.product_installed?(product1), "product #{product1} should not be installed")
    assert(!installer.product_installed?(product2), "product #{product2} should not be installed")

    Wixgem::Wix.make_installation("test/wixgem_multiple.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
    Wixgem::Wix.make_installation("test/wixgem_multiple.1.1.0.msi", {version: '1.1.0.0', product_name: product2, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})

 	  install_msi('test\\wixgem_multiple.1.0.0.msi') do |installdir|
    assert(installer.product_installed?(product1), "The product should be installed")
	
	  properties1 = installer.installation_properties(product1)
	  assert(properties1['VersionString'] == '1.0.0.0', "The version should be 1.0.0.0")

 	  install_msi('test\\wixgem_multiple.1.1.0.msi') do |installdir1|
	    assert(installer.product_installed?(product2))
	    properties2 = installer.installation_properties(product2)
	    assert(properties2['VersionString'] == '1.1.0.0', "should install version 1.1.0.0")
	  
	    assert(installer.product_installed?(product1), "version 1.0.0 should still be installed")

	    assert(properties1['ProductCode'] != properties2['ProductCode'], "product codes for version 1.0.0 and 1.0.0 should be different")
	  end
	end
  end

  def test_remove_previous_version
    product1='wixgem_install 1.0'
    product2='wixgem_install 1.1'
	
    installer = WindowsInstaller.new
    assert(!installer.product_installed?(product1), "product #{product1} should not be installed")
    assert(!installer.product_installed?(product2), "product #{product2} should not be installed")
	
	  Wixgem::Wix.make_installation("test/wixgem_install.1.0.0.msi", {version: '1.0.0.0', product_name: product1, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['Gemfile']})
	  Wixgem::Wix.make_installation("test/wixgem_install.1.1.0.msi", {version: '1.1.0.0', product_name: product2, remove_existing_products: true, upgrade_code: '{face46ab-74ce-44eb-a2b7-81a8cfad5bab}', files: ['rakefile.rb']})
	
	  installer.install_msi('test\\wixgem_install.1.0.0.msi')
	  assert(installer.product_installed?(product1), "should install version 1.0.0")

	  install_msi('test\\wixgem_install.1.1.0.msi') do |installdir|
	    assert(installer.product_installed?(product2), "should install version 1.1.0")	  
      assert(!installer.product_installed?(product1), "#{product1} should have been uninstalled when #{product2} was installed")
	  end
  end
end

