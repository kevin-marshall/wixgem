require 'rexml/document'

module Wixgem

class Shortcut
  
  def initialize(file, hash)
    @file = file
	@hash = hash
  end
  
  def create(xml_doc)
	return xml_doc
  end
end

end
