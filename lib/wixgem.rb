require 'fileutils'
require 'tmpdir.rb'
require 'rexml/document'
require "#{File.dirname(__FILE__)}/command.rb"
require 'SecureRandom'
require_relative('file.rb')
require_relative('shortcut.rb')

module Wixgem

class Wix
  def self.initialize
    @install_path = ''
	@debug = false
	@logger = nil
	@log_file = nil
  end
  def self.install_path=(path)
    @install_path = path
  end
  def self.install_path
    return @install_path
  end
  
  def self.debug=(bool)
    @debug = bool
  end
  def self.debug
    return @debug
  end
  
  def self.make_mergemodule(output_file, input)
    gem_dir = File.dirname(__FILE__)
    create_package(output_file, input)
  end
  
  def self.make_installation(output_file, input)
    gem_dir = File.dirname(__FILE__)
    create_package(output_file, input)
  end
  
  private   
  def self.start_logger
    @logger = []
  end

  def self.end_logger
    @logger = nil
  end
  
  def self.manage_upgrade(xml_doc, input)
	product = REXML::XPath.match(xml_doc, '//Wix/Product')
	return xml_doc if(product.length == 0)

 	if(input.has_key?(:remove_existing_products) && input[:remove_existing_products])
	  raise 'Hash must have a version key if the hash has a :remove_existing_products key' unless(input.has_key?(:version))
	  raise 'Hash must have an upgrade_code key if the hash has a :remove_existing_products key' unless(input.has_key?(:upgrade_code))
	
	  upgrade = product[0].add_element 'Upgrade', { 'Id' => input[:upgrade_code] }
	  upgrade.add_element 'UpgradeVersion', { 'Minimum' => input[:version], 'OnlyDetect'=>'yes', 'Property'=>'NEWERVERSIONDETECTED' }
	  upgrade.add_element 'UpgradeVersion', { 'Minimum' => '0.0.0', 'IncludeMinimum'=>'yes','Maximum'=>input[:version],'IncludeMaximum'=>'no','Property'=>'OLDERVERSIONBEINGUPGRADED' }

	  install_and_execute = REXML::XPath.match(xml_doc, '//Wix/Product/InstallExecuteSequence')
	  install_and_execute[0].add_element 'RemoveExistingProducts', { 'After'=>'InstallValidate' }
	end
	
	return xml_doc
  end  

  def self.manage_custom_actions(xml_doc, input)
    # Example custom action
	#<CustomAction Id='comReg' Directory='INSTALLLOCATION' Execute='deferred' Impersonate='no' ExeCommand='"[NETFRAMEWORK40CLIENTINSTALLROOTDIR]regasm.exe" "[INSTALLLOCATION]EAWordImporter.dll" /codebase' Return='check' />

    manufacturer = 'Default Manufacturer'
    manufacturer = input[:manufacturer] if(input.has_key?(:manufacturer))
	
	install_path = '[ProgramFilesFolder][ProductName]'
	install_path = "[ProgramFilesFolder][Manufacturer]\\[ProductName]" unless(manufacturer == 'Default Manufacturer')

	product = REXML::XPath.match(xml_doc, '//Wix/Product')
	return xml_doc if(product.length == 0)
	
	product[0].add_element 'CustomAction', { 'Id' => 'SetTARGETDIR', 'Property' => 'TARGETDIR', 'Value' => "#{install_path}", 'Execute' => 'firstSequence', 'Return' => 'check'}

	install_execute_sequence = product[0].add_element 'InstallExecuteSequence'
	custom_action = install_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }

	install_ui_sequence = product[0].add_element 'InstallUISequence'
	custom_action = install_ui_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }
	
	admin_execute_sequence = product[0].add_element 'AdminExecuteSequence'
	custom_action = admin_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }

	admin_ui_sequence = product[0].add_element 'AdminUISequence'
	custom_action = admin_ui_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }

	return xml_doc
  end
  
  def self.manage_msm_files(xml_doc)	
	merge_modules = {}
	component_group = REXML::XPath.match(xml_doc, '//Wix/Fragment/ComponentGroup')
	component_group.each { |component_group|
	  component_group.each_element('Component') { |component|
	    component.each_element('File') { |file|
		  merge_modules[component] = file if(File.extname(file.attributes['Source']) == '.msm')
		}
	  }
	}
	return xml_doc if(merge_modules.length == 0)
	
	directory_root = REXML::XPath.match(xml_doc, '//Wix/Product/Directory')
	if(directory_root.length == 0)
		module_root = REXML::XPath.match(xml_doc, '//Wix/Module')
		raise 'Merge modules can not be added to a merge module' unless(module_root.nil?)
		raise 'Wix element //Wix/Product/Directory does not exist'
	end
	
	default_feature = REXML::XPath.match(xml_doc, '//Wix/Product/Feature')

	merge_modules.each { |component,file|	
	  id = component.attributes['Id'].gsub('cmp','merge')
	  directory_root[0].add_element 'Merge', { 'Id' => id, 'SourceFile' => file.attributes['Source'], 'Language' => '1033', 'DiskId' => '1'}
	  default_feature[0].add_element 'MergeRef', { 'Id' => id }
	  
	  component_group[0].delete_element(component)
    }
	
	return xml_doc
  end

  def self.manage_read_only_files(xml_doc,input)
	install_files = files(input)
	
	install_files.each do |file| 
	  absolute_path = file
	  absolute_path = "#{input[:original_pwd]}/#{file}" unless(File.exists?(file))
	  
	  if(File.read_only?(absolute_path))
	    install_path = ".\\#{self.modify_file_path(input, file)}"
		file_elements = REXML::XPath.match(xml_doc, "//File[@Source='#{install_path}']")
		file_elements[0].attributes['ReadOnly'] = 'yes' if(file_elements.length == 1)
	  end
	end
	
	return xml_doc
  end
  
  def self.manage_shortcuts(xml_doc,input)
	return xml_doc unless(input.has_key?(:shortcuts))
	
	input[:shortcuts].each do |file, shortcut_hash|
	  shortcut = Shortcut.new(file, shortcut_hash)
	  xml_doc = shortcut.create(xml_doc)
	end
	
	return xml_doc
  end
  
  def self.modify_file_path(input, file)
    return file unless(input.kind_of?(Hash) && input.has_key?(:modify_file_paths))
  
    modify_paths = input[:modify_file_paths]
    modify_paths.each { |regex, replacement_string| file = file.gsub(regex, replacement_string) }
  
    return file
  end

  def self.files(input)
    files = input
    files = input[:files] if(input.kind_of?(Hash))
    return files
  end

  def self.ignore_files(input)
    files = []
    files = input[:ignore_files] if(input.kind_of?(Hash) && input.has_key?(:ignore_files))
    
    return files
  end
  
  def self.copy_install_files(directory, input)
	files = files(input)

	missing_files = []
	files.each do |file| 
	  if(File.file?(file))
   	    install_path = file
        if(input.has_key?(:modify_file_paths))
          input[:modify_file_paths].each { |regex, replacement_string| install_path = install_path.gsub(regex, replacement_string) }
        end
		raise "Invalid relative installation path: #{install_path}" if(install_path.include?(':'))

   	    install_path = "#{directory}/#{install_path}"		
		FileUtils.mkpath(File.dirname(install_path)) unless(Dir.exists?(File.dirname(install_path)))
		FileUtils.cp(file, install_path, { preserve: true })
	  elsif(!File.exists?(file))
	    missing_files.insert(missing_files.length, file)
	  end
	end

    if(@debug)	
	  if(files.length > 0)
		max_path = files.max { |a, b| a.length <=> b.length }
		columen_size = max_path.length + 10
	  end
	    
	  @logger << "------------------------------------ Installation Paths -----------------------------------" unless(@logger.nil?)
	  @logger << "%-#{columen_size}s %s\n" % ['File path', 'Installation Path']  unless(@logger.nil?)
	  files.each do |file| 
	    if(File.file?(file))
  	      install_path = file
          if(input.has_key?(:modify_file_paths))
            input[:modify_file_paths].each { |regex, replacement_string| install_path = install_path.gsub(regex, replacement_string) }
          end
	      @logger << "%-#{columen_size}s %s\n" % [file, install_path]  unless(@logger.nil?)
        end
      end
      
	  if(input.has_key?(:ignore_files))
	    @logger << "------------------------------------ ignoring files -----------------------------------" unless(@logger.nil?)
		input[:ignore_files].each { |file| @logger << file }
	  end
	  
	  @logger << "-------------------------------------------------------------------------------------------" unless(@logger.nil?)
	end

	raise 'No files were given to wixgem' if(files.length == 0)

	if(missing_files.length > 0)
	  missing_files_str = ''
	  missing_files.each { |f| 
	    if(missing_files_str.empty?)
	      missing_files_str = f 
		else
	      missing_files_str = "#{missing_files_str}, #{f}" 
		end
	  }
	  raise "Wixgem missing files: #{missing_files_str}" 
	end
  end

  def self.log_wix_output(cmd)
	return unless(@debug && !@logger.nil?)
	
	@logger << "----------------------------------------------------------------------------"
	@logger << cmd
	
	if(!cmd[:output].empty?)
	  @logger << "--------------------------- std output -----------------------------------"
	  @logger << cmd[:output]
	end
	
	if(!cmd[:error].empty?)
	  @logger << "--------------------------- std error ------------------------------------"
	  @logger << cmd[:error]
	end
  end
  
  def self.modify_heat_commandline(input, cmd)
  	cmd = cmd.gsub(/-srd/, '-svb6 -srd') if(input.has_key?(:has_vb6_files) && input[:has_vb6_files])
	cmd = cmd.gsub(/-srd/, '-sreg -srd') if(input.has_key?(:suppress_registry_harvesting) && input[:suppress_registry_harvesting])
	cmd = cmd.gsub(/-srd/, '-scom -srd') if(input.has_key?(:suppress_COM_elements) && input[:suppress_COM_elements])
	return cmd
  end

  def self.execute_heat(input, cmd_line_options)		  
	heat_cmd = Command.new("\"#{install_path}/bin/heat.exe\" #{modify_heat_commandline(input, cmd_line_options)}", { quiet: true })
	heat_cmd.execute	
	log_wix_output(heat_cmd)
  end
  
  def self.execute_heat_file(wxs_file, input, template_option)
	install_files = files(input)
	modified_paths = []
    install_files.each { |file| modified_paths << modify_file_path(input, file) }
	install_files = modified_paths
	
	install_ignore_files = ignore_files(input) 
	modified_paths = []
    install_ignore_files.each { |file| modified_paths << modify_file_path(input, file) }
	install_ignore_files = modified_paths
	
	install_files.reject! { |f| install_ignore_files.include?(f) }

	package_type = 'installation'
	package_type = 'merge module' if(template_option.include?('module'))
	raise "At least one file is required to build a #{package_type}" if(install_files.length == 0)
	
	directory_fragments = {}
	wxs_files = {}
	install_files.each do |file|
	  windows_path = file.gsub(/\//, '\\')
	  
	  filename = wxs_file
	  if(install_files.index(file) == 0)
        execute_heat(input, "file \"#{windows_path}\" #{template_option} -cg InstallionFiles -gg -nologo -srd -o  \"#{filename}\"")
	  else
		filename = File.basename(wxs_file).gsub('.wxs', "-#{wxs_files.length}.wxs") 
		execute_heat(input, "file \"#{windows_path}\" -template fragment -gg -nologo -srd -o  \"#{filename}\"")
		wxs_files[file] = filename
 	  end

	  directory_fragments[File.dirname(file)] = "dir#{SecureRandom.uuid.gsub(/-/,'')}"
	  xml_doc = REXML::Document.new(File.read(filename))
	  file_elements = REXML::XPath.match(xml_doc, '//Wix/Fragment/DirectoryRef/Component/File')
	  file_elements[0].attributes['Source'] = "SourceDir\\#{file.gsub(/\//,'\\')}" if(file_elements.length == 1)
	  file_elements[0].attributes['Id'] = "fil#{SecureRandom.uuid.gsub(/-/,'')}" if(file_elements.length == 1) # Assigning new Id, because the id is somehow generated from the filename. So it is possible for heat to generate duplicate id's
	  File.open(filename, 'w') { |f| f.puts(xml_doc.to_s) }	
	end
	directory_fragments['.'] = 'TARGETDIR'
	
	xml_doc = REXML::Document.new(File.read(wxs_file))

	wix_elements = REXML::XPath.match(xml_doc, '//Wix')
	raise "Invalid wxs file: #{wxs_file}" unless(wix_elements.length == 1)
	
	directory_fragments.each do |key, id|
	  if(key != '.')
		  fragment_element = wix_elements[0].add_element 'Fragment'
		  directory_ref_element = fragment_element.add_element 'DirectoryRef', { 'Id' => directory_fragments[File.dirname(key)] }
		  directory_ref_element.add_element 'Directory', { 'Id' => id, 'Name' => File.basename(key) }
	  end
 	end
	
	component_group_element = REXML::XPath.match(xml_doc, '//Wix/Fragment/ComponentGroup')
	raise "Failed to create installation package for file: #{wxs_file}" unless(component_group_element.length == 1)

	wxs_files.each do |file, filename|
	  xml_fragment_doc = REXML::Document.new(File.read(filename))
	  component_elements = REXML::XPath.match(xml_fragment_doc, '//Wix/Fragment/DirectoryRef/Component')
	  
	  component_elements.each do |component_element| 
	    component_element.attributes['Id'] = "cmp#{SecureRandom.uuid.gsub(/-/,'')}" # Assigning new Id, because the id is somehow generated from the filename. So it is possible for heat to generate duplicate id's
	    component_element = component_group_element[0].add_element component_element, { 'Directory' =>  directory_fragments[File.dirname(file)] } 
      end		
	end

	formatter = REXML::Formatters::Pretty.new(2)
	formatter.compact = true # This is the magic line that does what you need!
	xml_text=''
	formatter.write(xml_doc, xml_text)
	File.open(wxs_file, 'w') { |f| f.puts xml_text }
  end
  
  def self.execute_heat_dir(wxs_file, input, template_option)
	execute_heat(input,"dir . #{template_option} -cg InstallionFiles -gg -nologo -srd -o  \"#{wxs_file}\"")
  end
  
  def self.create_wxs_file(wxs_file, input, ext)
    template_option = "-template product"
	template_option = "-template module" unless(ext == ".msi")

	if(input.has_key?(:ignore_files))
		execute_heat_file(wxs_file, input, template_option)
	else
		execute_heat_dir(wxs_file, input, template_option)
	end
	
	product_name = File.basename(wxs_file, '.wxs')
    product_name = input[:product_name] if(input.has_key?(:product_name))
	
    manufacturer = 'Not Set'
    manufacturer = input[:manufacturer] if(input.has_key?(:manufacturer))

	product_version = ''
    product_version = input[:version] if(input.has_key?(:version))

	product_code = ''
	product_code = input[:product_code] if(input.has_key?(:product_code))

	upgrade_code = ''
	upgrade_code = input[:upgrade_code] if(input.has_key?(:upgrade_code))
	
	wxs_text = File.read(wxs_file)

	wxs_text = wxs_text.gsub(/SourceDir\\/) { |s| s = '.\\' }
	wxs_text = wxs_text.gsub(/PUT-PRODUCT-NAME-HERE/) { |s| s = product_name }
	wxs_text = wxs_text.gsub(/PUT-MODULE-NAME-HERE/) { |s| s = product_name }
	wxs_text = wxs_text.gsub(/PUT-COMPANY-NAME-HERE/) { |s| s = manufacturer }
	wxs_text = wxs_text.gsub(/PUT-FEATURE-TITLE-HERE/) { |s| s = 'Files to Install' }

	wxs_text = wxs_text.gsub(/Version=\"1.0.0.0\"/) { |s| s = "Version=\"#{product_version}\"" } unless(product_version.empty?)
	wxs_text = wxs_text.gsub(/Product Id=\"[^\"]+\"/) { |s| s = "Product Id=\"#{product_code}\"" } unless(product_code.empty?)
	wxs_text = wxs_text.gsub(/UpgradeCode=\"[^\"]+\"/) { |s| s = "UpgradeCode=\"#{upgrade_code}\"" } unless(upgrade_code.empty?)
	
	xml_doc = REXML::Document.new(wxs_text)
	packages = REXML::XPath.match(xml_doc, '//Wix/Product/Package')
	packages.each do |package| 
		package.add_attribute('InstallScope', 'perMachine') if(input.has_key?(:all_users))
		package.attributes['InstallerVersion'] = 450
		package.attributes['InstallerVersion'] = (input[:installer_version]*100).to_i if(input.has_key?(:installer_version))
	end 

	xml_doc = manage_custom_actions(xml_doc, input)
	xml_doc = manage_upgrade(xml_doc,input)
	xml_doc = manage_msm_files(xml_doc)
	xml_doc = manage_read_only_files(xml_doc,input)
	xml_doc = manage_shortcuts(xml_doc, input)
	
	File.open(wxs_file, 'w') { |f| f.puts(xml_doc.to_s) }	
    #formatter = REXML::Formatters::Pretty.new(2)
    #formatter.compact = true # This is the magic line that does what you need!
	#wxs_text = ''
	#formatter.write(xml, wxs_text)
	#File.open(wxs_file, 'w') { |f| f.puts(wxs_text) }	
  end

  def self.create_output(wxs_file, output)
    wixobj_file = "#{File.basename(wxs_file,'.wxs')}.wixobj"
	
	candle_cmd = Command.new("\"#{install_path}/bin/candle.exe\" -out \"#{wixobj_file}\" \"#{wxs_file}\"", { quiet: true })
	candle_cmd.execute	
	log_wix_output(candle_cmd)
	
	light_cmd = Command.new("\"#{install_path}/bin/light.exe\" -nologo -out \"#{output}\" \"#{wixobj_file}\"", { quiet: true })
	light_cmd.execute
	log_wix_output(light_cmd)
  end

  def self.verify_input_keys(input)
	input[:files].reject! { |f| File.directory?(f) }

    [:files,:ignore_files].each { |key| raise "Hash key #{key} cannot be nil" if(input.has_key?(key) && input[key].nil?)}	
  end
  
  def self.create_package(output, input)
    raise 'WIX path is not set!' if(install_path.nil?)
	input = { files: input } unless(input.kind_of?(Hash))
	verify_input_keys(input)
	  	
	@debug = input[:debug] if(!@debug && input.has_key?(:debug))

	start_logger if(@debug)
	
	FileUtils.mkpath(File.dirname(output)) unless(Dir.exists?(File.dirname(output)))
	
	ext = File.extname(output)
  	basename = File.basename(output, ext)
	FileUtils.rm(output) if(File.exists?(output))
 
	output_absolute_path = File.absolute_path(output)
	input[:original_pwd] = Dir.pwd

	#dir = './tmp_dir'
	#FileUtils.rm_rf(dir) if(Dir.exists?(dir))
	#FileUtils.mkdir(dir)
	Dir.mktmpdir do |dir|
	  wxs_file = "#{basename}.wxs"	    
	  begin
		copy_install_files(dir, input)
	  
		Dir.chdir(dir) do |current_dir|
		  create_wxs_file(wxs_file, input, ext)
	      create_output(wxs_file, output_absolute_path)
		end
	  rescue Exception => e
		raise "Wixgem exception: #{e}"
	  ensure
	    FileUtils.cp("#{dir}/#{wxs_file}", "#{output_absolute_path}.wxs") if(File.exists?("#{dir}/#{wxs_file}") && @debug)
	    File.open("#{output_absolute_path}.log", 'w') { |f| f.puts(@logger) } if(@debug &!@logger.nil?)
	  end	  
	end
	
	pdb_file = output_absolute_path.gsub(ext,'.wixpdb')
	FileUtils.rm(pdb_file) if(File.exists?(pdb_file))
	
	end_logger if(@debug)
  end
end

end