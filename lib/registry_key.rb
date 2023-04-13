##require 'rexml/document'
#require 'SecureRandom'

#module Wixgem

# https://support.firegiant.com/hc/en-us/articles/230912127-RegistryKey-and-RegistryValue-elements
class RegistryKey
  def initialize(xml_doc, input)
    @xml_doc = xml_doc
    @input = input
  end
  def add(registry_key)
    unless(registry_key.key?(:root) && registry_key.key?(:key) && registry_key.key?(:value))
      raise 'Registry key must have root, key, and value elements' 
	end

	key_value = registry_key[:value]
    unless(key_value.key?(:name) || key_value.key?(:value) || key_value.key?(:type))
		raise 'Registry value must have name, value, and type elements' 
	end

	registry_keys_component = REXML::XPath.match(@xml_doc, "//Component[@Id='RegistryKeys']")
	if(registry_keys_component.size == 0)
		wix_element = REXML::XPath.match(@xml_doc, "/Wix")[0]
		fragment = wix_element.add_element 'Fragment'
		component_group = fragment.add_element 'ComponentGroup'
		component_group.attributes['Id'] = "rk_#{SecureRandom.uuid.gsub(/-/,'')}"

		default_feature = REXML::XPath.match(@xml_doc, '//Wix/Product/Feature')
		component_ref = default_feature[0].add_element 'ComponentGroupRef', 'Id' => component_group.attributes['Id']

		component = component_group.add_element 'Component'
		component.attributes['Id'] = 'RegistryKeys'
		component.attributes['Directory'] = 'INSTALLDIR'
	else
		puts "component: #{registry_keys_component.to_s}"
	end
		
	registry_key_element = component.add_element 'RegistryKey', { 'Root' => registry_key[:root], 'Key' => registry_key[:key] }
	value_element = registry_key_element.add_element 'RegistryValue', { 'Action' => 'write', 'Name' => key_value[:name], 'Value' => key_value[:value], 'Type' => key_value[:type] }
   end
end