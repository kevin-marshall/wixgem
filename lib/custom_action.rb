require 'rexml/document'
require 'SecureRandom'

module Wixgem

class CustomAction
  def initialize(xml_doc, input)
    @xml_doc = xml_doc
    @input = input
  end
  def add(custom_action)
    unless(custom_action.key?(:file) || custom_action.key?(:binary_key) || custom_action.key?(:property))
      raise 'Currently, only supported custom actions work with installed executable, binary key, or property' 
	  end
	
	  file_key=nil
	  if(custom_action.key?(:file))
      install_path = ".\\#{custom_action[:file].gsub(/\//,'\\')}"
	    file_elements = REXML::XPath.match(@xml_doc, "//File[@Source='#{install_path}']")
	    raise "Unable to locate installation file '#{custom_action[:file]} for custom action'" if(file_elements.nil? || (file_elements.size == 0))
	
	    file_key = file_elements[0].attributes['Id']
	  end
	
	  id = "ca_#{SecureRandom.uuid.gsub(/-/,'')}"
	  id = custom_action[:id] if(custom_action.key?(:id))
		
	  impersonate = 'yes'
	  impersonate = custom_action[:impersonate] if(custom_action.key?(:impersonate))
	
	  condition='NOT Installed AND NOT REMOVE'
	  condition='1' if(custom_action.key?(:binary_key))
	  condition = custom_action[:condition] if(custom_action.key?(:condition))
	
	  execute='deferred'
	  execute = custom_action[:execute] if(custom_action.key?(:execute))
	
	  ret='check'
	  ret = custom_action[:return] if(custom_action.key?(:return))
	
	  wix_element = REXML::XPath.match(@xml_doc, "/Wix")[0]
	  fragment = wix_element.add_element 'Fragment'
	
	  action = fragment.add_element 'CustomAction', { 'Id' => id, 'Impersonate' => impersonate, 'Return' => ret, 'HideTarget' => 'no', 'Execute' => execute }
	  if(custom_action.key?(:binary_key))
	    action.attributes['BinaryKey'] = custom_action[:binary_key]
	  else
	    action.attributes['FileKey'] = file_key
	  end

		action.attributes['Directory'] = custom_action[:directory] if(custom_action.key?(:directory))
  	action.attributes['ExeCommand'] = custom_action[:exe_command] if(custom_action.key?(:exe_command))
	  action.attributes['DllEntry'] = custom_action[:dll_entry] if(custom_action.key?(:dll_entry))

	  if(custom_action.key?(:property))
	    raise "Custom action property '#{custom_action[:property]} must have a value!" unless(custom_action.key?(:value))
	    action.attributes.delete('ExeCommand')
	    action.attributes.delete('Return')
	    action.attributes['Property'] = custom_action[:property]
	    action.attributes['Value'] = custom_action[:value]	  
	  end
	
    install_execute_sequence = fragment.add_element 'InstallExecuteSequence'

	  custom_action[:before] = 'InstallFinalize' if(!custom_action.key?(:after) && !custom_action.key?(:before))
 	  if(custom_action.key?(:after))
 	    action = install_execute_sequence.add_element 'Custom', { 'Action' => id, 'After' => custom_action[:after] }
      action.text = condition
 	  else
 	    action = install_execute_sequence.add_element 'Custom', { 'Action' => id, 'Before' => custom_action[:before] }
      action.text = condition
	  end
	
	  control=nil
	  elements = REXML::XPath.match(@xml_doc, "/Wix/Product")
	  elements = REXML::XPath.match(@xml_doc, "/Wix/Module") if(elements.nil? || elements.size == 0)
	
	  elements[0].add_element 'CustomActionRef', { 'Id' => id }
  end
end
end