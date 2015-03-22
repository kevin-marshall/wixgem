require 'win32ole'
require File.dirname(__FILE__) + '/command.rb'

module Wixgem
class WindowsInstaller
	def self.install(msi_file)
	  raise "#{msi_file} does not exist!" unless(File.exists?(msi_file))
	  msi_file = msi_file.gsub(/\//, '\\')
	  raise "#{msi_file} is already installed" if(WindowsInstaller.msi_installed?(msi_file))
	  execute("msiexec.exe /quiet /i #{msi_file}")
	end

	def self.uninstall(msi_file)
	  raise "#{msi_file} does not exist!" unless(File.exists?(msi_file))
	  
	  info = msi_records(msi_file)
	  uninstall_product_code(info['ProductCode'])
    end

	def self.uninstall_product_name(product_name)
	  raise "#{product_name} is not installed" unless(product_name_installed?(product_name))
	  uninstall_product_code(product_code_from_product_name(product_name))
    end
	
	def self.uninstall_product_code(product_code)
	  raise "#{product_code} is not installed" unless(product_code_installed?(product_code))
	  execute("msiexec.exe /quiet /x #{product_code}")
    end

	def self.msi_installed?(msi_file)  
	  info = msi_records(msi_file)
	  result = product_code_installed?(info['ProductCode'])
	  return result
	end	
	
	def self.product_name_installed?(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')	  
	  installer.Products.each { |prod_code|
		name = installer.ProductInfo(prod_code, "ProductName")
		return true if (product_name == name)
	  }
	  return false
	end

	def self.product_code_installed?(product_code)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  installer.Products.each { |installed_product_code| return true if (product_code == installed_product_code) }
	  return false
	end
	
	def self.product_code_installed?(product_code)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  installer.Products.each { |prod_code| return true if (product_code == prod_code) }
	  return false
	end
	
	def self.version_from_product_name(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  info = product_info(installer, product_code_from_product_name(product_name, installer))
	  return info['VersionString']
	end

	def self.product_code_from_product_name(product_name, installer = nil)
	  installer = WIN32OLE.new('WindowsInstaller.Installer') if(installer.nil?)
	  installer.Products.each { |prod_code|
		name = installer.ProductInfo(prod_code, "ProductName")
		return prod_code if (product_name == name)
	  }
	  raise "Failed to find product code for product: #{product_name}"
	end

	def self.product_info(installer, code)
	  raise 'Windows installer cannot be nil' if(installer.nil?)
	  hash = Hash.new
	  # known product keywords found on internet.  Would be nice to generate.
	  %w[Language PackageCode Transforms AssignmentType PackageName InstalledProductName VersionString RegCompany 
		 RegOwner ProductID ProductIcon InstallLocation InstallSource InstallDate Publisher LocalPackage HelpLink 
		 HelpTelephone URLInfoAbout URLUpdateInfo InstanceType].sort.each do |prop|
		value = installer.ProductInfo(code, prop)
		hash[prop] = value unless(value.nil? || value == '')
	  end
	  return hash
	end

	def self.msi_info(installer, msi_file)
	  raise 'Windows installer cannot be nil' if(installer.nil?)
	  hash = Hash.new
	  # known product keywords found on internet.  Would be nice to generate.
	  %w[Language PackageCode Transforms AssignmentType PackageName InstalledProductName VersionString RegCompany 
		 RegOwner ProductID ProductIcon InstallLocation InstallSource InstallDate Publisher LocalPackage HelpLink 
		 HelpTelephone URLInfoAbout URLUpdateInfo InstanceType].sort.each do |prop|
		value = installer.ProductInfo(code, prop)
		hash[prop] = value unless(value.nil? || value == '')
	  end
	  return hash
	end
	
	def self.dump_info(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  properties = product_info(installer, product_code_from_product_name(product_name, installer))
	  properties.each { |id, value| puts "#{id}: #{value}" }
	end

	private
	def self.msi_records(msi_file)
	  records = {}
	  
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  sql_query = "SELECT * FROM `Property`"

	  db = installer.OpenDatabase(msi_file, 0)
			
	  view = db.OpenView(sql_query)
	  view.Execute(nil)
			
	  record = view.Fetch()
	  return '' if(record == nil)

	  while(!record.nil?)
	    records[record.StringData(1)] = record.StringData(2) 
		record = view.Fetch()
	  end
	  db.ole_free
	  db = nil
	  installer.ole_free
	  installer = nil
	  
	  return records
	end
	
	def self.dump_msi_records(msi)
	  records = msi_records(msi)

	  puts "#{msi} Properties:"
	  records.each do |key,value|
		puts "#{key}: #{value}"
	  end
	end
	
	def self.dump_product(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  # only one session per process!
	  session = installer.OpenProduct(product_code?(product_name, installer))
	  db = session.Database
			
	  sql_query = "SELECT * FROM `Property`"
	  view = db.OpenView(sql_query)
	  view.Execute(nil)
			
	  record = view.Fetch()
	  return '' if(record == nil)

	  puts "Session Properties:"
	  while(!record.nil?)
		puts "#{record.StringData(1)}: #{record.StringData(2)}"
		record = view.Fetch()
	  end
	  db.ole_free
	  db = nil
	  installer.ole_free
	  installer = nil
	  puts ''
	end	

    def self.execute(cmd)
      command = Wixgem::Command.new(cmd, { quiet: true } )
	  #command[:debug] = true
      command.execute
    end
end
end
