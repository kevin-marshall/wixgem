def modify_path(data, file)
  return file unless(data.kind_of?(Hash) && data.has_key?(:modify_file_paths))
  
  modify_paths = data[:modify_file_paths]
  modify_paths.each { |regex, replacement_string| file = file.gsub(regex, replacement_string) }
  
  return file
end

def files(data)
  files = data
  if(data.kind_of?(Hash))
    files = data[:files] 
  end
  
  modified_paths = []
  files.each { |file| modified_paths << modify_path(data, file) }
  
  return modified_paths
end

def ignored_files(data)
  files = []

  if(data.kind_of?(Hash) && data.has_key?(:ignore_files))
    files = data[:ignore_files]
  end
    
  modified_paths = []
  files.each { |file| modified_paths << modify_path(data, file) }

  return modified_paths
end

def test_files_exist(msi_file, data)
  product_name = File.basename(msi_file, File.extname(msi_file))
  product_name = data[:product_name] if(data.kind_of?(Hash) && data.has_key?(:product_name))

  manufacturer = ''
  manufacturer = data[:manufacturer] if(data.kind_of?(Hash) && data.has_key?(:manufacturer))
 
  relative_install_dir = product_name
  raise "#{name}: relative_install_dir should be set to the product name" if(relative_install_dir.length == 0)
  relative_install_dir = "#{manufacturer}/#{relative_install_dir}" if(manufacturer.length > 0)
 
  file_array = files(data)
  ignored_files(data).each { |file| file_array.delete(file) }
  
  file_array.each { |file| 
    full_path = "C:/Program Files (x86)/#{relative_install_dir}/#{file}"
	raise "#{full_path} not installed." unless(File.exist?(full_path))
  }
  
  ignored_files(data).each { |file|
    full_path = "C:/Program Files (x86)/#{relative_install_dir}/#{file}"
	raise "#{full_path} should not be installed." if(File.exist?(full_path))
  }
end
