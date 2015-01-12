require 'dev_tasks'
require './admin.rb'

CLEAN.include('test')

WIX_DEP_PATH='OpenSource/WixToolset/3.9'
DEV[:files][:source].include('test_files/**/*')
DEV[:svn_exports][WIX_DEP_PATH] = 'https://deps.googlecode.com/svn/trunk/WixToolset/3.9'

WIX_PATH = "#{Environment.dev_root}/dep/#{WIX_DEP_PATH}"

Text.replace_text_in_glob './spec/wixpath.rb',/WIX_PATH='.+'/,"WIX_PATH='#{WIX_PATH}'"

unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator will not be able to run the installer'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end

# Yard command line for realtime feed back of Readme.md modifications
# yard server --reload