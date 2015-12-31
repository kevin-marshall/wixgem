require 'rake'

dir = File.dirname(__FILE__)
Dir.chdir(dir) do 
  test_files = Rake::FileList.new
  test_files.include("*.rb")
  test_files.exclude(__FILE__)
  test_files.exclude('COM_test.rb')
  
  test_files.each { |test_file| require_relative test_file }
end