require './admin.rb'
require 'dev'

WIX_VERSION='3.9'

CLEAN.include('test/**','wixgem-*.gem','wixgem_install*.msi')

SVN_EXPORTS={"OpenSource/WixToolset/#{WIX_VERSION}" => "https://deps.googlecode.com/svn/trunk/WixToolset/#{WIX_VERSION}"}

WIX_PATH = "#{Environment.dev_root}/dep/OpenSource/WixToolset/#{WIX_VERSION}"

Text.replace_in_glob './spec/wixpath.rb',/WIX_PATH='.+'/,"WIX_PATH='#{WIX_PATH}'"

task :commit => [:add]

task :setup do
	FileUtils.chmod('a-w', 'test_files/ReadOnly.txt')
end

unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator. Will not be able to test installing the msi files!'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload