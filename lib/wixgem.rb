require 'fileutils'
require 'SecureRandom'
require 'tmpdir.rb'
require 'rexml/document'

class Wix
  def self.initialize
    @install_path = ''
	@debug = false
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
  
  def self.make_mergemodule(output, input)
    gem_dir = File.dirname(__FILE__)
    apply_wix_template(output, input, "#{gem_dir}/templates/mergemodule.wxs")
  end
  
  def self.make_installation(output, input)
    gem_dir = File.dirname(__FILE__)
    apply_wix_template(output, input, "#{gem_dir}/templates/Install.wxs")
  end
  
  private   
  def self.manage_upgrade(xml_doc, input)
	product = REXML::XPath.match(xml_doc, '//Wix/Product')
	return xml_doc if(product.length == 0)

    manufacturer = 'Not Set'
    manufacturer = input[:manufacturer] if(input.kind_of?(Hash) && input.has_key?(:manufacturer))
	
 	if(input.kind_of?(Hash) && 
	   input.has_key?(:remove_existing_products) && 
	   input[:remove_existing_products])

	  raise 'Hash must have a version key if the hash has a :remove_existing_products key' unless(input.has_key?(:version))
	  raise 'Hash must have an upgrade_code key if the hash has a :remove_existing_products key' unless(input.has_key?(:upgrade_code))
	
	  upgrade = product[0].add_element 'Upgrade', { 'Id' => input[:upgrade_code] }
	  upgrade.add_element 'UpgradeVersion', { 'Minimum' => input[:version], 'OnlyDetect'=>'yes', 'Property'=>'NEWPRODUCTFOUND' }
	  upgrade.add_element 'UpgradeVersion', { 'Minimum' => '1.0.0', 'IncludeMinimum'=>'yes','Maximum'=>input[:version],'IncludeMaximum'=>'no','Property'=>'UPGRADEFOUND' }

	  install_and_execute = REXML::XPath.match(xml_doc, '//Wix/Product/InstallExecuteSequence')
	  install_and_execute[0].add_element 'RemoveExistingProducts', { 'After'=>'InstallValidate' }
	end
	
	return xml_doc
  end  

  def self.manage_custom_actions(xml_doc, input)
    manufacturer = 'Not Set'
    manufacturer = input[:manufacturer] if(input.kind_of?(Hash) && input.has_key?(:manufacturer))
	
	install_path = '[ProgramFilesFolder][ProductName]'
	install_path = "[ProgramFilesFolder][Manufacturer]\\[ProductName]" unless(manufacturer == 'Not Set')

	product = REXML::XPath.match(xml_doc, '//Wix/Product')
	return xml_doc if(product.length == 0)
	
	product[0].add_element 'CustomAction', { 'Id' => 'SetTARGETDIR', 'Directory' => 'TARGETDIR', 'Value' => "#{install_path}", 'Return' => 'check'}

	install_execute_sequence = product[0].add_element 'InstallExecuteSequence'
	custom_action = install_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'After'=>'InstallValidate' }

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
	
	directory_root = REXML::XPath.match(xml_doc, '//Wix/Product/Directory')
	default_feature = REXML::XPath.match(xml_doc, '//Wix/Product/Feature')

	merge_modules.each { |component,file|	
	  id = component.attributes['Id'].gsub('cmp','merge')
	  directory_root[0].add_element 'Merge', { 'Id' => id, 'SourceFile' => file.attributes['Source'], 'Language' => '1033', 'DiskId' => '1'}
	  default_feature[0].add_element 'MergeRef', { 'Id' => id }
	  
	  component_group[0].delete_element(component)
    }
	
	return xml_doc
  end
  
  def self.copy_install_files(directory, input)
    files = input
	files = input[:files] if(input.kind_of?(Hash))
	
	raise 'No files were given to wixgem' if(files.length == 0)
	
	missing_files = []
	files.each do |file| 
	  if(File.file?(file))
   	    install_path = file
        if(input.kind_of?(Hash) && input.has_key?(:modify_file_paths))
          input[:modify_file_paths].each { |regex, replacement_string| install_path = install_path.gsub(regex, replacement_string) }
        end

   	    install_path = "#{directory}/#{install_path}"
		FileUtils.mkpath(File.dirname(install_path)) unless(Dir.exists?(File.dirname(install_path)))
		FileUtils.cp(file, install_path)
	  elsif(!File.exists?(file))
	    missing_files.insert(missing_files.length, file)
	  end
	end
	
	if(missing_files.length > 0)
	  missing_files_str = ''
	  missing_files.each { |f| msg = "#{missing_files_str}, #{f}" }
	  raise "Missing files: #{missing_files_str}" 
	end
  end

  def self.create_wxs_file(wxs_file, input, ext)
    template_option = "-template product"
	template_option = "-template module" unless(ext == ".msi")

	wix_cmd = "\"#{install_path}/bin/heat.exe\" dir . #{template_option} -cg InstallionFiles -gg -nologo -srd -o  \"#{wxs_file}\""
	wix_cmd = wix_cmd.gsub(/-srd/, '-svb6 -srd') if(input.kind_of?(Hash) && input.has_key?(:has_vb6_files))
	File.open("#{File.basename(wxs_file,'.wxs')}.wix_cmds", 'w') { |f| f.puts wix_cmd } if(@debug)
	
	stdout = %x[#{wix_cmd}]
	raise "#{stdout}\nFailed to generate .wxs file" unless(File.exists?(wxs_file))
		
	product_name = File.basename(wxs_file, '.wxs')
    product_name = input[:product_name] if(input.kind_of?(Hash) && input.has_key?(:product_name))
	
    manufacturer = 'Not Set'
    manufacturer = input[:manufacturer] if(input.kind_of?(Hash) && input.has_key?(:manufacturer))

	product_version = ''
    product_version = input[:version] if(input.kind_of?(Hash) && input.has_key?(:version))

	product_code = ''
	product_code = input[:product_code] if(input.kind_of?(Hash) && input.has_key?(:product_code))

	upgrade_code = ''
	upgrade_code = input[:upgrade_code] if(input.kind_of?(Hash) && input.has_key?(:upgrade_code))
	
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
	xml_doc = manage_custom_actions(xml_doc, input)
	xml_doc = manage_upgrade(xml_doc,input)
	xml_doc = manage_msm_files(xml_doc)
	
	File.open(wxs_file, 'w') { |f| f.puts(xml_doc.to_s) }	
    #formatter = REXML::Formatters::Pretty.new(2)
    #formatter.compact = true # This is the magic line that does what you need!
	#wxs_text = ''
	#formatter.write(xml, wxs_text)
	#File.open(wxs_file, 'w') { |f| f.puts(wxs_text) }	
  end

  def self.create_output(wxs_file, output)
    wixobj_file = "#{File.basename(wxs_file,'.wxs')}.wixobj"
	
	wix_cmd = "\"#{install_path}\\bin\\candle.exe\" -out \"#{wixobj_file}\" \"#{wxs_file}\""
	File.open("#{File.basename(wxs_file,'.wxs')}.wix_cmds", 'a') { |f| f.puts wix_cmd } if(@debug)
	stdout = %x[#{wix_cmd}]
	raise "#{stdout}\nFailed to generate .wixobj file" unless(File.exists?(wixobj_file))

	wix_cmd = "\"#{install_path}\\bin\\light.exe\" -nologo -out \"#{output}\" \"#{wixobj_file}\""
	File.open("#{File.basename(wxs_file,'.wxs')}.wix_cmds", 'a') { |f| f.puts wix_cmd } if(@debug)
    stdout = %x[#{wix_cmd}]	
	raise "#{stdout}\nFailed to generate #{output} file" unless(File.exists?(output))
  end

  def self.apply_wix_template(output, input, template)
    raise 'WIX path is not set!' if(install_path.nil?)

  	@debug = input[:debug] if(!@debug && input.kind_of?(Hash) && input.has_key?(:debug))
	FileUtils.mkpath(File.dirname(output)) unless(Dir.exists?(File.dirname(output)))
	
	ext = File.extname(output)
  	basename = File.basename(output, ext)
	FileUtils.rm(output) if(File.exists?(output))
 
	output_absolute_path = File.absolute_path(output)

	Dir.mktmpdir do |dir|
	  copy_install_files(dir, input)
	  
	  wxs_file = "#{basename}.wxs"	    
	  Dir.chdir(dir) do |current_dir|
	    begin
		  create_wxs_file(wxs_file, input, ext)
	      create_output(wxs_file, output_absolute_path)
		ensure
		  puts "HERE"
	      if(@debug)
	 	    puts "HERE1"
	        FileUtils.cp("#{wxs_file}", "#{output_absolute_path}.wxs") if(File.exists?(wxs_file))
		    wix_cmds_file = "#{File.basename(wxs_file,'.wxs')}.wix_cmds"
			puts "HERE2: #{wix_cmds_file}"
		    FileUtils.cp(wix_cmds_file, "#{File.dirname(output_absolute_path)}/#{wix_cmds_file}") if(File.exists?(wix_cmds_file))
	      end
		end
	  end
    end
	pdb_file = output_absolute_path.gsub(ext,'.wixpdb')
	FileUtils.rm(pdb_file) if(File.exists?(pdb_file))
  end
end