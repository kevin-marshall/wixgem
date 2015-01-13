require 'dev_tasks'
require './admin.rb'

WIX_VERSION='3.9'

CLEAN.include('test')

DEV[:files][:source].include('test_files/**/*')
DEV[:svn_exports]["OpenSource/WixToolset/#{WIX_VERSION}"] = "https://deps.googlecode.com/svn/trunk/WixToolset/#{WIX_VERSION}"

WIX_PATH = "#{Environment.dev_root}/dep/OpenSource/WixToolset/#{WIX_VERSION}"

#Text.replace_text_in_glob './spec/wixpath.rb',/WIX_PATH='.+'/,"WIX_PATH='#{WIX_PATH}'"

unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator will not be able to run the installer'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload