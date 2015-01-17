require '../WindowsInstaller.rb'
require 'win32ole'
require 'dev'

if(File.exists?('COMExample.msi'))
  WindowsInstaller.uninstall('COMExample.msi') if(WindowsInstaller.installed?('COMExample.msi'))
end

cmd = Command.new("E:/Development/dep/OpenSource/WixToolset/3.9/bin/candle.exe -out COMExample.wixobj COMExample.wxs")
cmd.execute

cmd = Command.new("E:/Development/dep/OpenSource/WixToolset/3.9/bin/light.exe -nologo -out COMExample.msi COMExample.wixobj")
cmd.execute

