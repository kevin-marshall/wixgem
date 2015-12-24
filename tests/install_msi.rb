require 'WindowsInstaller'

def install_msi(msi)
  installer = WindowsInstaller.new
  installer.install_msi(msi)
  
  msi_properties = installer.msi_properties(msi)
  installed_properties = installer.installation_properties(msi['ProductCode'])
  
  yield installed_properties['InstallLocation']
  
  installer.uninstall_msi(msi)
end