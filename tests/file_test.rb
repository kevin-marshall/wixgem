require 'minitest/autorun'
require_relative '../lib/file.rb'

class File_test < MiniTest::Unit::TestCase
  def test_read_only?
	assert(File.read_only?('test_files/ReadOnly.txt'), "test_files/ReadOnly.txt should be read only")	  
    assert(!File.read_only?('test_files/32145.txt'), "test_files/32145.txt should not be read_only")	  
  end
end

