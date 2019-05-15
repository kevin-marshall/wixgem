require 'WindowsInstaller'

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

def install_msi(msi, wix_hash=nil)
  test_msi(msi, wix_hash) unless(wix_hash.nil?)
  
  installer = WindowsInstaller.new
  installer.install_msi(msi)
  
  msi_properties = installer.msi_properties(msi)
  installed_properties = installer.installation_properties(msi_properties['ProductCode'])
  
  begin
    yield installed_properties['InstallLocation'].gsub(/\\/,'/')
  rescue Exception => e
    raise e
  ensure
    installer.uninstall_msi(msi)
  end
end