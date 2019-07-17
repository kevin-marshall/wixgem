require 'rexml/document'
require 'SecureRandom'

module Wixgem

class User
  def initialize(name, user_hash)
    @user_name = name
    @user_hash = user_hash
  end
  def create(xml_doc)
    wix = REXML::XPath.match(xml_doc, "/Wix")[0]
    wix.add_attribute('xmlns:Util', 'http://schemas.microsoft.com/wix/UtilExtension')

    match = REXML::XPath.match(xml_doc, "/Wix")

    fragment = match[0].add_element 'Fragment'
    component_group = fragment.add_element 'ComponentGroup'
    component_group.add_attribute('Id', "cg_#{SecureRandom.uuid.gsub(/-/,'')}")
    component = component_group.add_element 'Component'
    component.add_attribute('Id', "c_#{SecureRandom.uuid.gsub(/-/,'')}")
    component.add_attribute('Directory', 'INSTALLDIR')
    
    user_element = component.add_element 'Util:User'
    user_element.add_attribute('Id', "user_#{SecureRandom.uuid.gsub(/-/,'')}")
    user_element.add_attribute('Name', @user_name)
    @user_hash.each { |attrib, value| user_element.add_attribute(attrib.to_s, value) }

    return xml_doc
  end
end
end
