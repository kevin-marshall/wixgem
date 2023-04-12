class RegistryEntries
  def initialize(hash)
	  @hash = hash
  end

  def create_key(xml_doc)
    raise "RegistryEntry hash is required to have a :root key" unless(@hash.has_key?(:root))
    raise "RegistryEntry hash is required to have a :path key" unless(@hash.has_key?(:path))
    raise "RegistryEntry hash is required to have a :key key" unless(@hash.has_key?(:key))
    raise "Key hash is required to have a :name key" unless(@hash[:key].has_key?(:name))
    raise "Key hash is required to have a :value key" unless(@hash[:value].has_key?(:name))
    raise "Key hash is required to have a :value key" unless(@hash[:value_type].has_key?(:name))

    service_exe = @hash[:service_exe]
    raise "Service #{file} does not exist" unless(File.exists?(service_exe))
    
    file_elements = REXML::XPath.match(xml_doc, "//File[@Source='.\\#{service_exe.gsub(/\//,'\\')}']")
    raise "Service #{@file} does not match a 'File' element with a 'Source' attribute in the wix generated wix file" if(file_elements.length == 0)
      
    service_exe_element = file_elements[0]
    service_exe_element.attributes['KeyPath']='yes'

	  create_service_element(xml_doc, service_exe_element)
	
	  return xml_doc
  end

  def set(xml_doc, input)
    file = file.gsub(/\//,'\\')
    file_elements = REXML::XPath.match(@xml_doc, "//File[@Source='.\\#{file}']")
	  raise "Unable to find file '#{file}' to associate with extension '#{extension}'" if(file_elements.nil? || file_elements.size != 1)

	file_parent = file_elements[0].parent
	
	app=File.basename(file)
    # App Paths to support Start,Run -> "myapp"
    #<RegistryValue Root="HKLM" Key="SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\MyApp.exe" Value="[!MyApp.exe]" Type="string" />
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\#{app}",
	                                           'Value' => "[INSTALLDIR]#{file}", 'Type' => 'string' }
    #<RegistryValue Root="HKLM" Key="SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\MyApp.exe" Name="Path" Value="[APPLICATIONFOLDER]" Type="string" />
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\#{app}", 
	                                           'Name' => 'Path', 'Value' => '[INSTALLDIR]', 'Type' => 'string' }

    # Extend to the "open with" list + Win7 jump menu pinning  
    #<RegistryValue Root="HKLM" Key="SOFTWARE\Classes\Applications\MyApp.exe\SupportedTypes" Name=".xyz" Value="" Type="string" />
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Classes\\Applications\\#{app}\\SupportedTypes", 
	                                           'Name' => extension, 'Value' => '', 'Type' => 'string' }
    #<RegistryValue Root="HKLM" Key="SOFTWARE\Classes\Applications\MyApp.exe\shell\open" Name="FriendlyAppName" Value="!(loc.ApplicationName)" Type="string" />
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Classes\\Applications\\#{app}\\shell\\open\\command", 
	                                           'Value' => "[INSTALLDIR]#{file} \"%1\"", 'Type' => 'string' }

    # MyApp.Document ProgID 
    #<RegistryValue Root="HKLM" Key="SOFTWARE\Classes\MyApp.Document" Name="FriendlyTypeName" Value="!(loc.DescXYZ)" Type="string" />
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Classes\\#{File.basename(app, '.exe')}.Document", 
	                                           'Name' => 'Aim Project File', 'Value' => "[INSTALLDIR]#{app} \"%1\"", 'Type' => 'string' }

	#<ProgId Id="MyApp.Document" Description="!(loc.DescXYZ)" Icon="filetype.ico" Advertise="yes">
    #    <Extension Id="xyz">
    #        <Verb Id="open" Command="!(loc.ExplorerMenuOpenXYZ)" Argument="&quot;%1&quot;" />
    #        <MIME Advertise="yes" ContentType="application/xyz" Default="yes" />
    #    </Extension>
    #</ProgId>
	prog_id = file_parent.add_element 'ProgId', { 'Id' => "#{File.basename(app, '.exe')}.Document", 'Description' => "Aim project file", 
	                                              'Advertise' => 'yes'}
    ext = prog_id.add_element 'Extension', { 'Id' => extension.gsub(/\./, '') }
	ext.add_element 'Verb', { 'Id' => 'open', 'Command' => "[INSTALLDIR]#{app}", 'Argument' => "\"%1\"" }
  end
end