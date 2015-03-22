require 'fiddle'

class File
  FILE_ATTRIBUTE_READONLY="0x1".hex		
  def self.read_only?(path)
    raise "'#{path}' does not exist" unless(File.exists?(path))
	kernel32 = Fiddle::Handle.new("kernel32")
	get_file_attributes = Fiddle::Function.new(kernel32['GetFileAttributesA'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_LONG)

	return ((get_file_attributes.call(path) & FILE_ATTRIBUTE_READONLY) == 1) ? true : false;
  end
end