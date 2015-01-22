require 'rspec'
require './lib/wixgem.rb'
require './lib/WindowsInstaller.rb'
require './spec/wixpath.rb'
require './spec/test_files_exist.rb'
require 'win32ole'
require './admin.rb'

if(admin?)
  describe 'Wixgem' do
    describe 'Installation of a COM object' do
	  it 'should not be able to instance a COM object' do
	    expect { WIN32OLE.new('COMObject.ComClassExample') }.to raise_error
	  end

	  installation_file = 'test\\wixgem_com_test.msi'	
	  installation_hash = { debug: true, all_users: 'perMachine', files: ['COMObject/bin/Release/COMObject.dll']}
	  it "should create an installation file using: #{installation_file}" do
        Wixgem::Wix.make_installation(installation_file, installation_hash)
	     expect(File.exists?(installation_file)).to be(true)	  
	  end
    
	  it 'should install' do
	   Wixgem::WindowsInstaller.install(installation_file)
	   expect(Wixgem::WindowsInstaller.msi_installed?(installation_file)).to be(true)
	  end

 	  it 'should have installed the COMObject.dll' do
        test_files_exist(installation_file, installation_hash)
	  end
	
	  # Allocating the COM object causes an issue when the install package is uninstalled.
	  # The msiexec reports Interrupt again to exit immediately. Need to spend some more
	  # time understanding what is going on with the uninstaller.
	  
	  # it 'should be able to instance a COM object with a GUID' do
		# object = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
		# expect(object.nil?).to eq(false)
		# expect(object.GetText).to eq('Hello World')
	  # end

#	  it 'should be able to instance a COM object with a Program Id' do		
#		object = WIN32OLE.new('COMObject.ComClassExample')
#		expect(object.nil?).to eq(false)
#		expect(object.GetText).to eq('Hello World')
#	  end
	
	  it 'should uninstall' do
	    Wixgem::WindowsInstaller.uninstall(installation_file) if(Wixgem::WindowsInstaller.msi_installed?(installation_file))
	  end
	end
  end
end
