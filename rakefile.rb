require 'dev'

CLEAN.include('test')

DEV[:dep][:wix_toolset] = { uri: 'https://deps.googlecode.com/svn/trunk/WixToolset/3.8', dir: 'OpenSource/WixToolset/3.8' }
DEV[:dep][:nunit]={uri: 'https://third-party.googlecode.com/svn/trunk/NUnit/2.6.3',dir:'google-third-party/NUnit/2.6.3'}
TASKS.refresh

WIX_PATH = "#{DEV[:dev_root]}/dep/#{DEV[:dep][:wix_toolset][:dir]}" if(ENV['WIX'].nil?)
CMD[:replace][:spec_COMObject] = { glob: 'spec/*.rb', search: /WIX_PATH='.+'/, replace: "WIX_PATH='#{WIX_PATH}'" }
CMD[:replace][:spec_regasm] = { glob: 'spec/*.rb', search: /REGASM='.+'/, replace: "REGASM='#{DEV[:paths][:regasm]}'" }
TASKS.refresh

CMD[:test] = ['rspec' ]

def admin?
  `net session`
  return true if $?==0
  return false
end

task :test => [:replace] do		
  unless(admin?)
	puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	puts 'Running as non administrator will not be able to run the installer'
	puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  end
end
