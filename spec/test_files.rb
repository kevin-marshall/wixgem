def test_files(arg)
  files = arg
  files = arg[:files] if(arg.kind_of?(Hash))

  files.each { |file| 
    full_path = "C:/Program Files (x86)/#{relative_install_dir}/#{file}"
	raise "#{name}: #{full_path} not installed." unless(File.exists?(full_path))
  }
end