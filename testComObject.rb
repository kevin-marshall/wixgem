require 'win32ole'

object = WIN32OLE.new('COMObject.ComClassExample')
puts "Object: #{object}"
puts "Text: #{object.GetText}"
