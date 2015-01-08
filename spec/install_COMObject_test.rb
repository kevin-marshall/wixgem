require 'rspec'
require './lib/wixgem.rb'
require 'systemu'
require 'win32ole'

require './spec/wixpath.rb'

COMOBJECT_PATH='ComObject/bin/AnyCPU/Release/COMObject.dll'
REGASM='C:/WINDOWS/Microsoft.NET/Framework/v4.0.30319/RegAsm.exe'

def execute(cmd)
  status, output, error = systemu(cmd)
  status_str = status.to_s
  raise "cmd: #{cmd}\nStatus: #{status_str}\nOutput: #{output}\nError: #{error}" unless(status_str.include?("exit 0"))
end

def test_com_installation(msi_file)
end

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
		
	msi_file = 'wixgem_COMServer.msi'
	Wix.make_installation(msi_file, {files: [COMOBJECT_PATH]})
	it "should install" do
      execute("msiexec.exe /i #{msi_file}")
	end

	it "should able to instance 'COMObject.ComClassExample'" do
	  #COMObject = WIN32OLE.new('COMObject.ComClassExample') 
	  #expect(COMObject).not_to eq(nil)
	end

	it "should uninstall" do
      execute("msiexec.exe /quiet /x #{msi_file}")
	  File.delete(msi_file)
	end
  end
end
