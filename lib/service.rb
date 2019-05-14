require 'rexml/document'
require 'SecureRandom'

module Wixgem

class Service
  
  def initialize(file, hash)
    @file = file
	  @hash = hash
  end
  
  def create(xml_doc)
	  raise "Service #{@file} does not exist" unless(File.exists?(@file))
	
	  file_elements = REXML::XPath.match(xml_doc, "//File[@Source='.\\#{@file.gsub(/\//,'\\')}']")
    raise "Service #{@file} does not match a 'File' element with a 'Source' attribute in the wix generated wix file" if(file_elements.length == 0)
      
    service_exe = file_elements[0]
    service_exe.attributes['KeyPath']='yes'

	  create_service_element(service_exe)
	
	  return xml_doc
  end
  
  private
  def create_service_element(file_element)
    Service_element = file_element.add_element 'ServiceInstall'

    raise "Service must have a name element" unless(@hash.has_key?(:name))
 
	  Service_element.attributes['Id'] = "Service_#{SecureRandom.uuid.gsub(/-/,'')}"
    Service_element.attributes['Type'] = 'ownProcess'
    Service_element.attributes['Name'] = @hash[:name]
    Service_element.attributes['DisplayName'] = "#{@hash[:name]} Service"
    Service_element.attributes['Description'] = "Description of #{@hash[:name]} Service"
    Service_element.attributes['Start'] = 'auto'
    Service_element.attributes['Account'] = 'auto'
	
	  return Service_element
  end
end

#end
