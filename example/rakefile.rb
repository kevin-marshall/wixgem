require 'wixgem'
	
#Wixgem::Wix.install_path = 'E:\Development\dep\OpenSource\WixToolset\3.9'
Wixgem::Wix.install_path = '<Path to the root directory of the wix toolset>'

task :create_installation_files do
  FileUtils.mkpath('./install_files/directory')
  sleep(1)
  File.open('./install_files/file1.txt', 'w') { |f| f.write('Hello World') }
  File.open('./install_files/directory/file2.txt', 'w') { |f| f.write('Hello World') }
end

task :mergemodule => [:create_installation_files] do
  installation_files = Dir.glob('./install_files/**/*')
  
  Wixgem::Wix.make_mergemodule('./example.msm', installation_files)
end

desc "Generate an installation msi file"
task :installation => [:mergemodule] do	  
  installation_files = Dir.glob('./example.msm')
  Wixgem::Wix.make_installation("./example.msi",  
    { upgrade_code: '{a62c35a7-6a6d-4392-822b-f6aca7eef88b}', 
	  files: installation_files } 
  )
end

task :default => [:installation]
