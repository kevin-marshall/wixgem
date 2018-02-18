require 'rexml/document'
require 'SecureRandom'

module Wixgem

class Shortcut
  
  def initialize(file, hash)
    @file = file
	  @hash = hash
  end
  
  def create(xml_doc)
	  raise "Shortcut #{@file} does not exist" unless(File.exists?(@file))
	
	  file_elements = REXML::XPath.match(xml_doc, "//File[@Source='.\\#{@file.gsub(/\//,'\\')}']")
	  raise "Shortcut #{@file} does not match a 'File' element with a 'Source' attribute in the wix generated wix file" if(file_elements.length == 0)
	  create_shortcut_element(file_elements[0])
	  create_directory(xml_doc, @hash[:directory]) if(@hash.has_key?(:directory))
	
	  return xml_doc
  end
  
  private
  def create_shortcut_element(file_element)
    shortcut_element = file_element.add_element 'Shortcut'
	
	  shortcut_element.attributes['Id'] = "Shortcut_#{SecureRandom.uuid.gsub(/-/,'')}"
	  shortcut_element.attributes['Arguments'] = @hash[:arguments] if(@hash.has_key?(:arguments))
	
	  shortcut_name = File.basename(@file)
	  if(@hash.has_key?(:name))
	    shortcut_name = @hash[:name] 
	  else
	    @hash[:name] = shortcut_name
	  end
	  shortcut_element.attributes['Name'] = shortcut_name

	  shortcut_element.attributes['Description'] = @hash[:description] if(@hash.has_key?(:description))
	  shortcut_element.attributes['Directory'] = 'DesktopFolder'
	
	  shortcut_element.attributes['Advertise']="yes"
	  shortcut_element.attributes['Advertise'] = "no" if(@hash.has_key?(:advertise) && !@hash[:advertise])
	  create_icon_element(shortcut_element) if(@hash.has_key?(:icon))
	
	  return shortcut_element
  end

  def create_icon_element(shortcut_element)
    icon_element = shortcut_element.add_element 'Icon'	
	  icon_element.attributes['Id'] = File.basename(@hash[:icon])
    icon_element.attributes['SourceFile'] = ".\\#{@hash[:icon].gsub(/\//, '\\')}"
	  return icon_element
  end

  def create_directory(xml_doc, directory)
	raise 'Currently only supporting desktop shortcuts' unless(directory == :desktop)
	if(directory == :desktop)
	  desktop_elements = REXML::XPath.match(xml_doc, "//DesktopFolder")
	  if(desktop_elements.length == 0)
		wix_elements = REXML::XPath.match(xml_doc, "//Wix")
		fragment_element = wix_elements[0].add_element 'Fragment'
		target_dir = fragment_element.add_element 'DirectoryRef', { 'Id' => 'TARGETDIR' }
		target_dir.add_element 'Directory', { 'Id' => 'DesktopFolder', 'Name' => 'Desktop' }
	  end
	end
  end
end

end
