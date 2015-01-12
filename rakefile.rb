ENV['Path'] = "#{ENV['Path']};C:\Program Files (x86)\Subversion\bin" if(Dir.exists?('C:\Program Files (x86)\Subversion\bin'))

require 'dev_tasks'
require './admin.rb'

CLEAN.include('test')

DEV[:files][:source].include('test_files/**/*')
DEV[:svn_exports]['OpenSource/WixToolset/3.8'] = 'https://deps.googlecode.com/svn/trunk/WixToolset/3.8'

WIX_PATH = "#{Environment.dev_root}/dep/OpenSource/WixToolset/3.8"

Text.replace_text_in_glob 'spec/*.rb',/WIX_PATH='.+'/,"WIX_PATH='#{WIX_PATH}'"

unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator will not be able to run the installer'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end
