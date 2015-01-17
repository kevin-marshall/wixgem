require 'win32ole'
require 'dev_tasks'

class WindowsInstaller
	def self.installed?(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  installer.Products.each { |prod_code|
		name = installer.ProductInfo(prod_code, "ProductName")
		return true if (product_name == name)
	  }
	  return false
	end

	def self.install(msi)
	  raise "#{msi} is already installed" if(WindowsInstaller.installed?(msi))
	end

	def self.uninstall(msi)
	  execute("msiexec.exe /quiet /x #{msi}") if(File.exists?(msi))
    end
	
	def self.product_code_installed?(product_code)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  installer.Products.each { |prod_code| return true if (product_code == prod_code) }
	  return false
	end
	
	def self.version?(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  info = product_info(installer, product_code?(product_name, installer))
	  return info['VersionString']
	end

	def self.product_code?(product_name, installer = nil)
	  installer = WIN32OLE.new('WindowsInstaller.Installer') if(installer.nil?)
	  installer.Products.each { |prod_code|
		name = installer.ProductInfo(prod_code, "ProductName")
		return prod_code if (product_name == name)
	  }
	  raise "Failed to find product code for product: #{product_name}"
	end

    private
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
	
	public
	def self.dump_info(product_name)
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  properties = product_info(installer, product_code?(product_name, installer))
	  properties.each { |id, value| puts "#{id}: #{value}" }
	end

	def self.msi_records(msi)
	  records = {}
	  
	  installer = WIN32OLE.new('WindowsInstaller.Installer')
	  sql_query = "SELECT * FROM `Property`"

	  db = installer.OpenDatabase(msi, 0)
			
	  view = db.OpenView(sql_query)
	  view.Execute(nil)
			
	  record = view.Fetch()
	  return '' if(record == nil)

	  while(!record.nil?)
	    records[record.StringData(1)] = record.StringData(2) 
		record = view.Fetch()
	  end
	  db = nil
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
	  db = nil
	  installer = nil
	  puts ''
	end	

    def execute(cmd)
      command = Command.new(cmd)
      command.execute
  
      raise "Failed: #{cmd} Status: #{command[:exit_code]}\nStdout: #{command[:output]}\nStderr: #{command[:error]}" unless(command[:exit_code] == 0)
    end
end

