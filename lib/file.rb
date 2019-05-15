require 'win32ole'

class File
  def self.read_only?(path)
    raise "'#{path}' does not exist" unless(File.exists?(path))
	
	  fso = WIN32OLE.new('Scripting.FileSystemObject')
    raise 'Failed to create Scripting.FileSystemObject' if(fso.nil?)
	  fo = fso.GetFile(path)
	
	  return ((fo.Attributes & 1) != 0) ? true : false
  end
end