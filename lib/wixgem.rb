require 'fileutils'
require 'SecureRandom'
require 'tmpdir.rb'

class Wix
  def self.install_path=(value)
    raise "WIX path '#{value}' does not exist" unless(Dir.exists?(value))
	@install_path = value
  end
  
  def self.install_path
	return @install_path
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
  def self.manage_msm_files(wxs_text)
	indent_merge = '			'
	indent_directory = '		'
	
	merge_ids = ''
	merge_refs = ''
	remove_components = []
	
	component = 0
	id = 1
	file = 2
	wxs_text.scan(/(?<component><Component Id=\"(?<id>[^\"]+)\".+Source=\"(?<file>.+\.msm)\".+Component>)/m) { |match|
	  merge_id = match[id].gsub('cmp','merge')
	  merge_ids = "#{merge_ids}#{indent_merge}<Merge Id='#{merge_id}' Language='1033' SourceFile='#{match[file]}' DiskId='1' />\n"
	  merge_refs = "#{indent_merge}#{merge_refs}<MergeRef Id='#{merge_id}' />\n#{indent_merge}"

	  remove_components.insert(remove_components.length, match[component])
	}
	
	remove_components.each { |cmp| wxs_text = wxs_text.gsub(cmp, '') }
	
	directory_element = "<Directory Id='TARGETDIR' Name='SourceDir'>\n#{merge_ids}#{indent_directory}</Directory>"
	wxs_text = wxs_text.gsub('<Directory Id="TARGETDIR" Name="SourceDir" />', directory_element)
	
	wxs_text = wxs_text.gsub(/\s+<\/Feature>/, "\n#{merge_refs}</Feature>")

	return wxs_text
  end
 
  def self.copy_install_files(directory, input)
    files = input
	files = input[:files] if(input.kind_of?(Hash))
	
	files.each do |file| 
	  if(File.file?(file))
   	    install_path = file
        if(input.kind_of?(Hash) && input.has_key?(:modify_install_path))
          input[:modify_install_path].each { |regex, replacement_string| install_path = install_path.gsub(regex, replacement_string) }
        end

   	    install_path = "#{directory}/#{install_path}"
		FileUtils.mkpath(File.dirname(install_path)) unless(Dir.exists?(File.dirname(install_path)))
		FileUtils.cp(file, install_path)
	  end
	end
  end

  def self.create_wxs_file(wxs_file, input, ext)
    template_option = "-template product"
	template_option = "-template module" unless(ext == ".msi")
	
	stdout = %x[\"#{install_path}/bin/heat.exe\" dir . #{template_option} -cg InstallionFiles -gg -nologo -srd -o  \"#{wxs_file}\"]
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

	install_path = '[ProgramFilesFolder][ProductName]'
	install_path = "[ProgramFilesFolder][Manufacturer]\\[ProductName]" unless(manufacturer == 'Not Set')
	
	custom_action = "
        <CustomAction Id='SetTARGETDIR' Property='TARGETDIR' Value='#{install_path}' Execute='firstSequence' />

		<InstallUISequence>
			<!-- Set TARGETDIR if it wasn't set on the command line -->
			<Custom Action='SetTARGETDIR' Before='CostFinalize'>TARGETDIR=\"\"</Custom>
		</InstallUISequence>

		<InstallExecuteSequence>
			<!-- Set TARGETDIR if it wasn't set on the command line -->
			<Custom Action='SetTARGETDIR' Before='CostFinalize'>TARGETDIR=\"\"</Custom>
		</InstallExecuteSequence>
	</Product>"	
	wxs_text = wxs_text.gsub(/<\/Product>/) { |s| s = custom_action }

	wxs_text = manage_msm_files(wxs_text)
		
	File.open(wxs_file, 'w') { |f| f.puts(wxs_text) }	
  end

  def self.create_output(wxs_file, output)
    wixobj_file = "#{File.basename(wxs_file)}.wixobj"
	
	stdout = %x[\"#{install_path}\\bin\\candle.exe\" -out \"#{wixobj_file}\" \"#{wxs_file}\"]
	raise "#{stdout}\nFailed to generate .wixobj file" unless(File.exists?(wixobj_file))

    stdout = %x[\"#{install_path}\\bin\\light.exe\" -nologo -out \"#{output}\" \"#{wixobj_file}\"]
	raise "#{stdout}\nFailed to generate #{output} file" unless(File.exists?(output))
  end

  def self.apply_wix_template(output, input, template)
    raise 'WIX path is not set!' if(install_path.nil?)
 
	ext = File.extname(output)
  	basename = File.basename(output, ext)
	FileUtils.rm(output) if(File.exists?(output))
 
	output_absolute_path = File.absolute_path(output)

    #dir = 'tmp_dir'
	#FileUtils.rm_rf(dir) if(Dir.exists?(dir))
	Dir.mktmpdir do |dir|
	  copy_install_files(dir, input)
	  
	  wxs_file = "#{basename}.wxs"	    
	  Dir.chdir(dir) do |current_dir|
		create_wxs_file(wxs_file, input, ext)
		create_output(wxs_file, output_absolute_path)
	  end
    end
	pdb_file = output_absolute_path.gsub(ext,'.wixpdb')
	FileUtils.rm(pdb_file) if(File.exists?(pdb_file))
  end
end