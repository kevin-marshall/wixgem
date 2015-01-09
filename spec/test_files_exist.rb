def files(data)
  files = data
  if(data.kind_of?(Hash))
    files = data[:files] 
  
    if(data.has_key?(:modify_install_path))
      modify_paths = data[:modify_install_path]
      files.each_index do |index|
	    puts "OldPath: #{files[index]}"
	    file_path = files[index]
	    modify_paths.each { |regex, replacement_string| file_path = file_path.gsub(regex, replacement_string) }
	    files[index] = file_path
	    puts "NewPath: #{files[index]}"
	  end
    end
  end
  return files
end

def test_files_exist(msi_file, data)
  files = files(data)

  product_name = File.basename(msi_file, File.extname(msi_file))
  product_name = data[:product_name] if(data.kind_of?(Hash) && data.has_key?(:product_name))

  manufacturer = ''
  manufacturer = data[:manufacturer] if(data.kind_of?(Hash) && data.has_key?(:manufacturer))
 
  relative_install_dir = product_name
  raise "#{name}: relative_install_dir should be set to the product name" if(relative_install_dir.length == 0)
  relative_install_dir = "#{manufacturer}/#{relative_install_dir}" if(manufacturer.length > 0)
 
  files.each { |file| 
    full_path = "C:/Program Files (x86)/#{relative_install_dir}/#{file}"
	raise "#{full_path} not installed." unless(File.exists?(full_path))
  }
end