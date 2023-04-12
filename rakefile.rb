require 'raykit'
require 'rbconfig'
require_relative 'lib/admin.rb'
require 'execute'

CLEAN.include('example/*.{wxs,msi,msm}','tests/test/**','tests/wixgem_install*.*', 'tests/Gemfile',
              'tests/**/bin','tests/**/obj', 'tests/**/*.exe')

task :commit => [:add,:test]

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
    #puts "exe: #{RbConfig::CONFIG['bindir']}"
    cmd = Execute.new("#{RbConfig::CONFIG['bindir']}/rake.cmd")
    cmd.execute	
  end
  
  Dir.chdir('tests/CustomActionExe') do
    cmd = Execute.new('ocra hello_world.rb --windows --dll ruby_builtin_dlls\libssp-0.dll --dll ruby_builtin_dlls\libgmp-10.dll', {echo_output: false})
    cmd.execute	
  end
end

task :test => [:setup,:build] do
  msbuild_path = Raykit::MsBuild::msbuild_path()

  Dir.chdir('tests') do |path|
    puts "Path: #{path}"
    PROJECT.run("\"#{msbuild_path}/msbuild\" COMObject/COMObject.sln /p:Configuration=Release /p:Platform=\"Any CPU\"") 
    PROJECT.run("\"#{msbuild_path}/msbuild\" WindowsService/WindowsService.sln /p:Configuration=Release /p:Platform=\"Any CPU\"") 
  
    cmd = Execute.new("#{RbConfig::CONFIG['bindir']}/ruby.exe all_tests.rb", {echo_output: false})
	  cmd.execute	
  end
end

unless(admin?)
  puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  puts 'No user interaction requred when running rakefile as an administrator           '
  puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

task :default => [:commit]

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload