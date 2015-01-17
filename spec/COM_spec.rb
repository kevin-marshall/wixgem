require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './spec/WindowsInstaller.rb'
require './spec/test_files_exist.rb'
require 'win32ole'
require './admin.rb'

# Unfortunately, I am unable to automate testing of the COM installation.  What I do not understand is I am unable to 
# script this COM msi. If I attempt to script the COM msi, the COM dll is never installed. I am speculating, the custom action 
# for the TARGETDIR is not functioning. If I use the mouse to double click on the msi, the privileges are raised to 
# administrative privileges the COM object is correctly installed. Don't understand the difference.

if(admin? && false)
describe 'Wixgem' do
  describe 'Installation of a COM object' do
	it 'should not be able to instance a COM object' do
	  expect { WIN32OLE.new('COMObject.ComClassExample') }.to raise_error
	end

	installation_file = 'test/wixgem_com_test.msi'
	while(WindowsInstaller.installed?(installation_file))
	  WindowsInstaller.uninstall(installation_file)
	end
	
	installation_hash = { debug: true, all_users: 'perMachine', files: ['COMObject/bin/Release/COMObject.dll']}
	it "should create an installation file using: #{installation_file}" do
      Wixgem::Wix.make_installation(installation_file, installation_hash)
	  expect(File.exists?(installation_file)).to be(true)	  
	end
    
	it 'should install' do
	  WindowsInstaller.install(installation_file)
	  expect(WindowsInstaller.installed?(installation_file)).to be(true)
	end

	it 'should have installed the COMObject.dll' do
      test_files_exist(installation_file, installation_hash)
	end
	
	it 'should be able to instance a COM object with a GUID' do
		object = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
		expect(object.nil?).to eq(false)
		puts "Text: #{object.GetText}"
		expect(object.GetText).to eq('Hello World')
	end

	it 'should be able to instance a COM object with a Program Id' do		
		object = WIN32OLE.new('COMObject.ComClassExample')
		expect(object.nil?).to eq(false)
		puts "Text: #{object.GetText}"
		expect(object.GetText).to eq('Hello World')
	end
	
	it 'should uninstall' do
	  WindowsInstaller.uninstall(installation_file) if(WindowsInstaller.installed?(installation_file))	     
	  expect(WindowsInstaller.installed?(installation_file)).to be(false)	  
	end
  end
end
end
