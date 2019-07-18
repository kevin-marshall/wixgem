require 'rexml/document'
require 'SecureRandom'

#module Wixgem

class Service  
  def initialize(hash)
	  @hash = hash
  end
  
  def create(xml_doc)
    raise "Service hash is required to have a :service_exe key" unless(@hash.has_key?(:service_exe))
    raise "Service hash is required to have a :service key" unless(@hash.has_key?(:service))
    raise "Service hash is required to have a :name key" unless(@hash[:service].has_key?(:name))

    service_exe = @hash[:service_exe]
    raise "Service #{file} does not exist" unless(File.exists?(service_exe))
    
    file_elements = REXML::XPath.match(xml_doc, "//File[@Source='.\\#{service_exe.gsub(/\//,'\\')}']")
    raise "Service #{@file} does not match a 'File' element with a 'Source' attribute in the wix generated wix file" if(file_elements.length == 0)
      
    service_exe_element = file_elements[0]
    service_exe_element.attributes['KeyPath']='yes'

	  create_service_element(xml_doc, service_exe_element)
	
	  return xml_doc
  end
  
  private
  def create_service_element(xml_doc, service_exe_element)
    parent_element = service_exe_element.parent
    
    service = @hash[:service]
    service_control = {}
    service_control = @hash[:service_control] if(@hash.has_key?(:service))

    if(service.key?(:logonasservice))
      raise ':logonasservice requires an :account element' unless(service.key?(:account))
      
      wix = REXML::XPath.match(xml_doc, "/Wix")[0]
      wix.add_attribute('xmlns:Util', 'http://schemas.microsoft.com/wix/UtilExtension')

      user_element = parent_element.add_element 'Util:User'
 
      account = service[:account].gsub(/\\/, '/')
      if(account.include?('/'))
        words = account.split('/')
        user_element.add_attribute('Domain', words[0])
        
        account = words[1]
      end
      user_element.attributes['Id'] = "logon_as_service_#{SecureRandom.uuid.gsub(/-/,'')}"
      user_element.add_attribute('Name', account)
      user_element.add_attribute('LogonAsService', service[:logonasservice])
      user_element.add_attribute('CreateUser', 'no')
      user_element.add_attribute('UpdateIfExists', 'yes')

      service.delete(:logonasservice)
      service.delete(:domain) if(service.key?(:domain))
    end 
    service_element = parent_element.add_element('ServiceInstall')

    service_element.attributes['Id'] = "Service_#{SecureRandom.uuid.gsub(/-/,'')}"
    service_element.attributes['Name'] = service[:name]
    service_element.attributes['ErrorControl'] = 'normal'
    service_element.attributes['Start'] = 'demand'
    service_element.attributes['Type'] = 'ownProcess'

    service_control_element = parent_element.add_element 'ServiceControl'
    service_control_element.attributes['Id'] = "ServiceControl_#{SecureRandom.uuid.gsub(/-/,'')}"
    service_control_element.attributes['Name'] = service[:name]

    service.each { |attribute, value| service_element.attributes[symbol_to_id(attribute)] = value }
    service_control.each { |attribute, value| service_control_element.attributes[symbol_to_id(attribute)] = value }    

	  return service_element
  end
  def symbol_to_id(symbol)
    service_map = {
      account: 'Account',
      arguments: 'Arguments',
      description: 'Description',
      display_name: 'DisplayName',
      erase_description: 'EraseDescription',
      error_control: 'ErrorControl',
      id: 'Id',
      interactive: 'Interactive',
      load_order_group:'LoadOrderGroup',
      name: 'Name',
      password: 'Password',
      start: 'Start',
      type: 'Type',
      vital: 'Vital'
    }

    return service_map[symbol] if(service_map.has_key?(symbol))

    service_control_map = {
      id: 'Id',
      name: 'Name',
      remove: 'Remove',
      start: 'Start',
      stop: 'Stop',
      wait: 'Wait'
    }
    return service_control_map[symbol]
  end
end

