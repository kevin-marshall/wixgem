require 'rexml/document'
require 'SecureRandom'

module Wixgem

class CustomAction
  
  def initialize(xml_doc)
    @xml_doc = file
	@actions = actions
	return if(has_product?)

 	elements = REXML::XPath.match(xml_doc, '//Wix/Product')
	@product = elements[0] if(elements.length == 1)
	return if(@product.nil?)

 	elements = REXML::XPath.match(xml_doc, '//Wix/Product/InstallExecuteSequence')
	if(elements.length == 1)
	  @install_execute_sequence = elements[0]
	else
	  @install_execute_sequence = @product.add_element 'InstallExecuteSequence'
	end
  end
  def set_target_directory
	raise 'Unable to set target directory custom action if the product is not defined' if(@product.nil?)
	
	manufacturer = 'Default Manufacturer'
    manufacturer = input[:manufacturer] if(input.has_key?(:manufacturer))
	
	install_path = '[ProgramFilesFolder][ProductName]'
	install_path = "[ProgramFilesFolder][Manufacturer]\\[ProductName]" unless(manufacturer == 'Default Manufacturer')
	
	@product.add_element 'SetProperty', { 'Id' => 'ARPINSTALLLOCATION', 'Value' => "#{install_path}", 'After' => 'CostFinalize', 'Sequence' => 'both' }	
	@product.add_element 'CustomAction', { 'Id' => 'SetTARGETDIR', 'Property' => 'TARGETDIR', 'Value' => "#{install_path}", 'Execute' => 'firstSequence', 'Return' => 'check'}

	custom_action = @install_execute_sequence.add_element 'Custom', { 'Action' => 'SetTARGETDIR', 'Before'=>'CostInitialize' }
  end
  def add(custom_action)
	raise 'Unable to add a custom action if the product is not defined' if(@product.nil?)
   
    raise 'Currently, only supported custom action is an executable' unless(custom_action.key?(:file))
	
    install_path = ".\\#{custom_action[:file].gsub(/\//,'\\')}"
	file_elements = REXML::XPath.match(@xml_doc, "//File[@Source='#{install_path}']")
	raise "Unable to locate installation file '#{custom_action[:file]}'" if(file_elements.nil?)
	
	file_key = file_elements[0].attributes['Id']
	id = "act#{SecureRandom.uuid.gsub(/-/,'')}"
	id = custom_action[:id] if(custom_action.key?(:id))
	cmd_line = ''
	cmd_line = custom_action[:exe_command] if(custom_action.key?(:exe_command))
	impersonate = 'yes'
	impersonate = custom_action[:impersonate] if(custom_action.key?(:impersonate))
	flags='1'
	flags = custom_action[:flags] if(custom_action.key?(:flags))
	execute='deferred'
	execute = custom_action[:execute] if(custom_action.key?(:execute))
	ret='check'
	ret = custom_action[:return] if(custom_action.key?(:return))
	
	action = @product.add_element 'CustomAction', { 'Id' => id, 'FileKey' => file_key, 'ExeCommand' =>  cmd_line,   
	                                                'Impersonate' => impersonate, 'Return' => ret, 'HideTarget' => 'no', 'Execute' => execute }
	 
	action = @install_execute_sequence.add_element 'Custom', { 'Action' => custom_action[:id], 'Before'=>'InstallFinalize' }
    action.text = flags
  end
