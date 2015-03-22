require 'rspec'
require './lib/file.rb'

describe 'File' do
  describe 'read_only?' do
    it "test_files/ReadOnly.txt should be read only" do
	  expect(File.read_only?('test_files/ReadOnly.txt')).to be(true)	  
	end
   
	it "test_files/32145.txt should not be read_only" do
	  expect(File.read_only?('test_files/32145.txt')).to be(false)	  
	end
  end
end