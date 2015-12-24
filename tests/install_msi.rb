require 'WindowsInstaller'

def install_msi(msi)
  installer = WindowsInstaller.new
  installer.install_msi(msi)
  
  msi_properties = installer.msi_properties(msi)
  installed_properties = installer.installation_properties(msi_properties['ProductCode'])
  
  begin
    yield installed_properties['InstallLocation'].gsub(/\\/,'/')
  rescue Exception => e
    raise e
  ensure
    installer.uninstall_msi(msi)
  end
end