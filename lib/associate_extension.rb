class AssociateExtension
  def initialize(xml_doc)
    @xml_doc = xml_doc
  end

  def associate(file, extension)
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
	file_parent.add_element 'RegistryValue', { 'Root' => 'HKLM', 'Key' => "SOFTWARE\\Classes\\#{File.basename(app, '.exe')}.Document\\shell\\open\\command", 
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
	ext.add_element 'Verb', { 'Id' => 'open', 'Command' => "[INSTALLDIR]#{app}", 'Argument' => "&quot;%1&quot;" }
  end
end