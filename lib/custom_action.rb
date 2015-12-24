require 'rexml/document'
require 'SecureRandom'

module Wixgem

class CustomAction
  def initialize(xml_doc, input)
    @xml_doc = xml_doc
    @input = input

 	elements = REXML::XPath.match(xml_doc, '//Wix/Product')
	return if(elements.nil? || (elements.length != 1))
	@product = elements[0] 
	return if(@product.nil?)

 	elements = REXML::XPath.match(xml_doc, '//Wix/Product/InstallExecuteSequence')
	if(elements.length == 1)
	  @install_execute_sequence = elements[0]
	else
	  @install_execute_sequence = @product.add_element 'InstallExecuteSequence'
	end
  end
  def installion_path
	manufacturer = 'Default Manufacturer'
    manufacturer = @input[:manufacturer] if(@input.has_key?(:manufacturer))
	
	install_path = '[ProgramFilesFolder][ProductName]'
	install_path = "[ProgramFilesFolder][Manufacturer]\\[ProductName]" unless(manufacturer == 'Default Manufacturer')
	return install_path
  end
  def set_target_directory
	wix_element = REXML::XPath.match(@xml_doc, "/Wix")[0]
	fragment = wix_element.add_element 'Fragment'
	
	fragment.add_element 'SetProperty', { 'Id' => 'ARPINSTALLLOCATION', 'Value' => "#{installion_path}", 'After' => 'CostFinalize', 'Sequence' => 'both' }	
	fragment.add_element 'CustomAction', { 'Id' => 'SetTARGETDIR', 'Property' => 'TARGETDIR', 'Value' => "#{installion_path}", 'Execute' => 'firstSequence', 'Return' => 'check'}

	custom_action = @install_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }
  end
  def add(custom_action)
    unless(custom_action.key?(:file) || custom_action.key?(:binary_key))
      raise 'Currently, only supported custom actions work with installed executable or binary key' 
	end
	
	file_key=nil
	if(custom_action.key?(:file))
      install_path = ".\\#{custom_action[:file].gsub(/\//,'\\')}"
	  file_elements = REXML::XPath.match(@xml_doc, "//File[@Source='#{install_path}']")
	  raise "Unable to locate installation file '#{custom_action[:file]} for custom action'" if(file_elements.nil?)
	
	  file_key = file_elements[0].attributes['Id']
	end
	
	id = "ca_#{SecureRandom.uuid.gsub(/-/,'')}"
	id = custom_action[:id] if(custom_action.key?(:id))
	
	cmd_line = ''
	cmd_line = custom_action[:exe_command] if(custom_action.key?(:exe_command))
	
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
	
	action = fragment.add_element 'CustomAction', { 'Id' => id, 'ExeCommand' =>  cmd_line, 'Impersonate' => impersonate, 'Return' => ret, 'HideTarget' => 'no', 'Execute' => execute }
	if(custom_action.key?(:binary_key))
	  action.attributes['BinaryKey'] = custom_action[:binary_key]
	else
	  action.attributes['FileKey'] = file_key
	end
	
	action = @install_execute_sequence.add_element 'Custom', { 'Action' => id, 'Before'=>'InstallFinalize' }
    action.text = condition
  end
end

end