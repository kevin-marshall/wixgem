require 'dev'
require 'rbconfig'
require_relative 'lib/admin.rb'
require 'cmd'

WIX_VERSION='3.9'

CLEAN.include('example/*.wxs','tests/test/**','tests/wixgem_install*.*', 'tests/rakefile.rb', 'tests/Gemfile')

SVN_EXPORTS={"OpenSource/WixToolset/#{WIX_VERSION}" => "https://deps.googlecode.com/svn/trunk/WixToolset/#{WIX_VERSION}"}

task :commit => [:add]

task :setup do
	FileUtils.chmod('a-w', 'tests/test_files/ReadOnly.txt')
end

task :add => [:clean]

task :pre_build do
  Dir.glob('**/*.wxs').each { |f| File.delete(f) } # Default build task tries to build these
end

task :build => [:pre_build] do
  Dir.chdir('example') do
    cmd = CMD.new("#{RbConfig::CONFIG['bindir']}/rake.bat")
    cmd.execute	
  end
  
  Dir.chdir('tests/CustomActionExe') do
    cmd = CMD.new('ocra hello_world.rb', {echo_output: false})
    cmd.execute	
  end
end


task :test => [:setup] do
  Dir.chdir('tests') do
	MSBuild.get_build_commands 'COMObject/COMObject.sln'
  
    cmd = CMD.new("#{RbConfig::CONFIG['bindir']}/ruby.exe all_tests.rb", {echo_output: false})
	cmd.execute	
  end
end
unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator. Will not be able to test installing the msi files!'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload