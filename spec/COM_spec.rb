require 'rspec'
require './lib/wixgem.rb'
require './spec/wixpath.rb'
require './WindowsInstaller.rb'
require 'win32ole'

describe 'Wixgem' do
  describe 'Installation of a COM object' do
	it 'should not be able to instance a COM object' do
	  expect { WIN32OLE.new('COMObject.ComClassExample') }.to raise_error
	end

	installation_file = 'test/wixgem_com_test.msi'
	while(WindowsInstaller.installed?(installation_file))
	  WindowsInstaller.uninstall(installation_file)
	end
	
	it "should create an installation file using: #{installation_file}" do
      Wix.make_installation(installation_file, { debug: true, files: ['COMObject/bin/Release/COMObject.dll']})
	  expect(File.exists?(installation_file)).to be(true)	  
	end
    
	WindowsInstaller.install(installation_file)

	it 'should be able to instance a COM object with a GUID' do
		#object = WIN32OLE.new('{863AEADA-EE73-4f4a-ABC0-3FB384CB41AA}')
		#expect(object.nil?).to eq(false)
		#puts "Text: #{object.GetText}"
		#expect(object.GetText).to eq('Hello World')
	end

	it 'should be able to instance a COM object with a Program Id' do
		
		#object = WIN32OLE.new('COMObject.ComClassExample')
		#expect(object.nil?).to eq(false)
		#puts "Text: #{object.GetText}"
		#expect(object.GetText).to eq('Hello World')
	end
	
	WindowsInstaller.uninstall(installation_file) if(WindowsInstaller.installed?(installation_file))
  end
end
