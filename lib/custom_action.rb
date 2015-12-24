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
	raise 'Unable to set target directory custom action if the product is not defined' if(@product.nil?)
	
	@product.add_element 'SetProperty', { 'Id' => 'ARPINSTALLLOCATION', 'Value' => "#{installion_path}", 'After' => 'CostFinalize', 'Sequence' => 'both' }	
	@product.add_element 'CustomAction', { 'Id' => 'SetTARGETDIR', 'Property' => 'TARGETDIR', 'Value' => "#{installion_path}", 'Execute' => 'firstSequence', 'Return' => 'check'}

	custom_action = @install_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }
  end
  def add(custom_action)
	raise 'Unable to add a custom action if the product is not defined' if(@product.nil?)
   
    raise 'Currently, only supported custom action is an executable' unless(custom_action.key?(:file))
	
    install_path = ".\\#{custom_action[:file].gsub(/\//,'\\')}"
	file_elements = REXML::XPath.match(@xml_doc, "//File[@Source='#{install_path}']")
	raise "Unable to locate installation file '#{custom_action[:file]} for custom action'" if(file_elements.nil?)
	
	file_key = file_elements[0].attributes['Id']
	id = "act#{SecureRandom.uuid.gsub(/-/,'')}"
	id = custom_action[:id] if(custom_action.key?(:id))
	
	cmd_line = ''
	cmd_line = custom_action[:exe_command] if(custom_action.key?(:exe_command))
	
	impersonate = 'yes'
	impersonate = custom_action[:impersonate] if(custom_action.key?(:impersonate))
	
	#condition='1' Until binary entries are supported, the default should be install only
	condition='NOT Installed AND NOT REMOVE'
	condition = custom_action[:condition] if(custom_action.key?(:condition))
	
	execute='deferred'
	execute = custom_action[:execute] if(custom_action.key?(:execute))
	
	ret='check'
	ret = custom_action[:return] if(custom_action.key?(:return))
	
	action = @product.add_element 'CustomAction', { 'Id' => id, 'FileKey' => file_key, 'ExeCommand' =>  cmd_line,   
	                                                'Impersonate' => impersonate, 'Return' => ret, 'HideTarget' => 'no', 'Execute' => execute }
	 
	action = @install_execute_sequence.add_element 'Custom', { 'Action' => id, 'Before'=>'InstallFinalize' }
    action.text = condition
  end
end

end