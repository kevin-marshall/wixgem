require 'rspec'
require './lib/wixgem.rb'
require './spec/execute.rb'
require './spec/wixpath.rb'
require 'systemu'
require 'win32ole'

COMOBJECT_PATH='ComObject/bin/Release/COMObject.dll'
REGASM='C:/WINDOWS/Microsoft.NET/Framework/v4.0.30319/RegAsm.exe'

describe 'COMObject' do    
  it "#{COMOBJECT_PATH} should exist" do
    expect(File.exists?(COMOBJECT_PATH)).to be(true) 
  end
  
  describe 'test COM server' do
	it "should not be able to instance 'COMObject.ComClassExample'" do
	  expect { COMObject = WIN32OLE.new('COMObject.ComClassExample') }.to raise_error
	end

	it "should be able to instance 'COMObject.ComClassExample'" do
      execute("#{REGASM} #{COMOBJECT_PATH} /codebase")
	end

	it "should not be able to instance 'COMObject.ComClassExample'" do
	  execute("#{REGASM} /u #{COMOBJECT_PATH}")
	  expect { COMObject = WIN32OLE.new('COMObject.ComClassExample') }.to raise_error
	end
  end

  describe 'test installing COM server' do
	Wix.install_path = WIX_PATH
		
	msi_file = 'test/wixgem_COMServer.msi'
	Wix.make_installation(msi_file, {debug: true, files: [COMOBJECT_PATH]})
	it "should install" do
     execute("msiexec.exe /i #{msi_file}")
	end

	it "should able to instance 'COMObject.ComClassExample'" do
	  #COMObject = WIN32OLE.new('COMObject.ComClassExample') 
	  #expect(COMObject).not_to eq(nil)
	end

	it "should uninstall" do
      #execute("msiexec.exe /quiet /x #{msi_file}")
	  #File.delete(msi_file)
	end
  end
end
