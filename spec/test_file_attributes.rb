def test_file_attributes(msi_file, data)
  product_name = File.basename(msi_file, File.extname(msi_file))
  product_name = data[:product_name] if(data.kind_of?(Hash) && data.has_key?(:product_name))

  manufacturer = ''
  manufacturer = data[:manufacturer] if(data.kind_of?(Hash) && data.has_key?(:manufacturer))
 
  install_sub_dir = product_name
  raise "#{name}: install_sub_dir should be set to the product name" if(install_sub_dir.length == 0)
  install_sub_dir = "#{manufacturer}/#{install_sub_dir}" if(manufacturer.length > 0)

  files = data
  if(data.kind_of?(Hash))
    files = data[:files] 
  end
  
  file_map = {}
  files.each { |file| file_map[file] = modify_path(data, file) }
  
  file_map.each { |file,installed_file| 
    full_path = "C:/Program Files (x86)/#{install_sub_dir}/#{file}"
	raise "File read only attribute differs between #{file} and #{installed_file}" unless(File.writable?(file) != File.writable?(installed_file))
  }
end