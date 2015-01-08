require 'dev_tasks'

CLEAN.include('test')

DEV[:svn_exports]['OpenSource/WixToolset/3.8'] = 'https://deps.googlecode.com/svn/trunk/WixToolset/3.8'

WIX_PATH = ENV['WIX']
WIX_PATH = "#{Environment.dev_root}/dep/OpenSource/WixToolset/3.8" if(ENV['WIX'].nil?)

Text.replace_text_in_glob 'spec/*.rb',/WIX_PATH='.+'/,"WIX_PATH='#{WIX_PATH}'"

def admin?
  `net session`
  return true if $?==0
  return false
end

unless(admin?)
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'Running as non administrator will not be able to run the installer'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
end
