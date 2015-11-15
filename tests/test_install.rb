require 'WindowsInstaller'

require_relative '../lib/admin.rb'

def get_product_name(msi_file, wix_hash)
  product_name = File.basename(msi_file, File.extname(msi_file))
  product_name = wix_hash[:product_name] if(wix_hash.has_key?(:product_name))
  
  return product_name
end

def test_msi(msi_file, wix_hash)
  product_name = get_product_name(msi_file, wix_hash)
	
  installer = WindowsInstaller.new
  msi_info = installer.msi_properties(msi_file)
  #puts msi_info.to_s
  
  if(wix_hash.has_key?(:product_name))
    raise "ProductName is #{msi_info['ProductName']} expected #{product_name}" unless(product_name == msi_info['ProductName'])
  end

  if(wix_hash.has_key?(:product_code))
    expected = wix_hash[:product_code].upcase
	raise "ProductCode is #{msi_info['ProductCode']} expected #{expected}" unless(expected == msi_info['ProductCode'])
  end

  if(wix_hash.has_key?(:upgrade_code))
    expected = wix_hash[:upgrade_code].upcase
	raise "UpgradeCode is #{msi_info['UpgradeCode']} expected #{expected}" unless(expected == msi_info['UpgradeCode'])
  end
  
  expected_product_version = '1.0.0.0'
  expected_product_version = wix_hash[:version] if(wix_hash.has_key?(:version))
  raise "Invalid product version #{msi_info['ProductVersion']}" if(msi_info['ProductVersion'] != expected_product_version)

  expected_manufacturer = 'Not Set'
  expected_manufacturer = wix_hash[:manufacturer] if(wix_hash.has_key?(:manufacturer))
  raise "Invalid Manufacturer #{msi_info['Manufacturer']}" if(msi_info['Manufacturer'] != expected_manufacturer)
end

def test_install(name, msi_file, wix_hash, callback=nil)
  wix_hash = { files: wix_hash} unless(wix_hash.kind_of?(Hash))
  msi_file = msi_file.gsub(/\//) { |s| s = '\\' }
  test_msi(msi_file, wix_hash)
  
  installer = WindowsInstaller.new

  msi_info = installer.msi_properties(msi_file)
  product_name = msi_info['ProductName']
	
  if(admin?)
	while(installer.product_installed?(product_name))
	  installer.uninstall_product(product_name)
	end
    raise "#{name}: Uninstall #{product_name} before running tests" if(installer.product_installed?(product_name))
    
	installer.install_msi(msi_file)			
	raise "#{name}: Product name #{product_name} is not installed" unless(installer.product_installed?(product_name))

	eval callback unless(callback == nil)
	 
	installer.uninstall_msi(msi_file) if(installer.product_installed?(product_name))
	raise "Failed to uninstall product #{product_name}" if(installer.product_installed?(product_name))
  end
end
