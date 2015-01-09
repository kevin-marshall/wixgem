require './WindowsInstaller.rb'
require 'dev_tasks'

def execute(cmd)
  command = Command.new(cmd)
  command.execute
  puts "" unless(command[:exit_code] == 0)
  raise "Failed: #{cmd} Status: #{command[:exit_code]}\nStdout: #{command[:output]}\nStderr: #{command[:error]}" unless(command[:exit_code] == 0)
end

def admin?
  %x[net session]
  return true if $?.to_i==0
  return false
end

def get_product_name(msi_file, arg2)
  product_name = File.basename(msi_file, File.extname(msi_file))
  product_name = arg2[:product_name] if(arg2.kind_of?(Hash) && arg2.has_key?(:product_name))
end

def test_msi(msi_file, arg2)
    product_name = get_product_name(msi_file, arg2)
	
	msi_info = WindowsInstaller.msi_records(msi_file)

	if(arg2.kind_of?(Hash) && arg2.has_key?(:product_name))
	  raise "ProductName is #{msi_info['ProductName']} expected #{product_name}" unless(product_name == msi_info['ProductName'])
	end

	if(arg2.kind_of?(Hash) && arg2.has_key?(:product_code))
	  expected = arg2[:product_code].upcase
	  raise "ProductCode is #{msi_info['ProductCode']} expected #{expected}" unless(expected == msi_info['ProductCode'])
	end
	
	expected_product_version = '1.0.0.0'
    expected_product_version = arg2[:version] if(arg2.kind_of?(Hash) && arg2.has_key?(:version))
    raise "Invalid product version #{msi_info['ProductVersion']}" if(msi_info['ProductVersion'] != expected_product_version)
end

def test_install(name, msi_file, arg2)
  msi_file = msi_file.gsub(/\//) { |s| s = '\\' }

  test_msi(msi_file, arg2)
  
  product_name = get_product_name(msi_file, arg2)
	
	if(admin?)
		begin
			while(WindowsInstaller.installed?(product_name))
			  execute("msiexec.exe /quiet /x #{msi_file}")
			end
			raise "#{name}: Unable to completely uninstall #{product_name}" if(WindowsInstaller.installed?(product_name))

			execute("msiexec.exe /i #{msi_file}")
			#WindowsInstaller.dump_info(product_name)
			
			relative_install_dir = product_name
			raise "#{name}: relative_install_dir should be set to the product name" if(relative_install_dir.length == 0)

			manufacturer = ''
			manufacturer = arg2[:manufacturer] if(arg2.kind_of?(Hash) && arg2.has_key?(:manufacturer))

			relative_install_dir = "#{manufacturer}/#{relative_install_dir}" if(manufacturer.length > 0)
			raise "#{name}: relative_install_dir is empty" if(relative_install_dir.length == 0)
			raise "#{name}: Product name #{msi_info['ProductName']} is not installed" unless(WindowsInstaller.installed?(msi_info['ProductName']))

			files = arg2
			files = arg2[:files] if(arg2.kind_of?(Hash))

			files.each { |file| 
			  full_path = "C:/Program Files (x86)/#{relative_install_dir}/#{file}"
			  raise "#{name}: #{full_path} not installed." unless(File.exists?(full_path))
			}
		
			execute("msiexec.exe /quiet /x #{msi_file}")
		ensure
			exectute("msiexec.exe /quiet /x #{msi_file}") if(WindowsInstaller.installed?(product_name))
		end
	end
end
