require 'dev'
require 'rbconfig'
require_relative 'lib/admin.rb'
require 'execute'

CLEAN.include('example/*.wxs','tests/test/**','tests/wixgem_install*.*', 'tests/rakefile.rb', 'tests/Gemfile')

task :commit => [:add]

task :setup do
	FileUtils.chmod('a-w', 'tests/test_files/ReadOnly.txt')
	raise 'Wixtoolset must be installed' if(ENV['WIX'].nil?)
end

task :add => [:clean]

task :pre_build do
  Dir.glob('**/*.wxs').each { |f| File.delete(f) } # Default build task tries to build these
end

task :build => [:pre_build] do
  Dir.chdir('example') do
    cmd = Execute.new("#{RbConfig::CONFIG['bindir']}/rake.bat")
    cmd.execute	
  end
  
  Dir.chdir('tests/CustomActionExe') do
    cmd = Execute.new('ocra hello_world.rb', {echo_output: false})
    cmd.execute	
  end
end


task :test => [:setup] do
  Dir.chdir('tests') do
	  MSBuild.get_build_commands 'COMObject/COMObject.sln'
	  MSBuild.get_build_commands 'WindowsService/WindowsService.sln'
    cmd = Execute.new("#{RbConfig::CONFIG['bindir']}/ruby.exe all_tests.rb", {echo_output: false})
	  cmd.execute	
  end
end

unless(admin?)
  puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  puts 'No user interaction requred when running rakefile as an administrator           '
  puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload