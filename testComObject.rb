require 'win32ole'

object = WIN32OLE.new('COMObject.ComClassExample')
puts "Object: #{object}"
puts "Text: #{object.GetText}"
object1 = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
puts "Object: #{object}"
puts "Text: #{object.GetText}"
