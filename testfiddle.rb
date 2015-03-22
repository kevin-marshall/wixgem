require 'fiddle'

#DWORD WINAPI GetFileAttributes(_In_  LPCTSTR lpFileName);
#Kernel32.dll
#floor = Fiddle::Function.new(
#  libm['floor'],
#  [Fiddle::TYPE_DOUBLE],
#  Fiddle::TYPE_DOUBLE
#)
#kernel32 = "#{ENV['SystemRoot'].gsub(/\//,'/')}/kernel32.dll"
#kernel64 = "#{ENV['SystemRoot'].gsub(/\//,'/')}/kernel64.dll"
#puts "Kernel32: #{File.exists?(kernel32)}"
#puts "Kernel64: #{File.exists?(kernel64)}"
#dll = fiddle.dlopen('')
require 'fiddle'
include Fiddle

Kernel32 = Handle.new("kernel32")
puts Kernel32.to_s
get_file_attributes = Function::Function.new(Kernel32['GetFileAttributesA'], [TYPE_VOIDP], TYPE_LONG)

FILE_ATTRIBUTE_READONLY="0x1".hex
puts "FILE_ATTRIBUTE_READONLY: #{FILE_ATTRIBUTE_READONLY.to_s(2)}"
result = get_file_attributes.call('test_files\\32145.txt')
puts "Attributes: #{result.to_s(2)} #{(result & FILE_ATTRIBUTE_READONLY).to_s(2)}"
puts "Test: #{(result & FILE_ATTRIBUTE_READONLY) == 1}"
result = get_file_attributes.call('test_files\\ReadOnly.txt')
puts "Attributes: #{result.to_s(2)} #{(result & FILE_ATTRIBUTE_READONLY).to_s(2)}"
puts "Test: #{(result & FILE_ATTRIBUTE_READONLY) == 1}"

