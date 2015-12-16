require 'WindowsInstaller' 

def test_msi(msi)
  installer = WindowsInstaller.new
  begin
	installer.install_msi(msi)
	yield
  rescue Exception => e
    raise e
  ensure
    installer.uninstall_msi(msi)
  end
end