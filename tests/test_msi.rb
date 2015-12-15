require 'WindowsInstaller' 

def test_msi(msi)
  installer = WindowsInstaller.new
  begin
	intaller.install_msi(installation_file)
	yield
  rescue Exception => e
    raise e
  ensure
    intaller.uninstall_msi(installation_file)
  end
end