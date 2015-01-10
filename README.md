# wixgem
Simple Ruby interface to facilitate creating and compiling simple windows installation files 
with the Wix Toolset.

## Installation
wixgem can be installed by the single command
 gem install wixgem

## Usage
The wix toolset must be installed.

## Simple usage

``
  require 'wixgem'
	
  WIX_TOOLSET_ROOT='path to root of Wix toolset'
  Wix.install_path = WIX_TOOLSET_ROOT

  # Installation example  
  Wix.make_installation('wixgem_install_test1.msi', ['rakefile.rb']])
  
  # Mergemodule example
  Wix.make_mergemodule('wixgem_install_test1.msi', ['rakefile.rb']])
```
  
  
In a rakefile define an installation task:

```
  require 'wixgem'
	
  WIX_TOOLSET_ROOT='path to root of Wix toolset'

  task :create_installation_files do
    FileUtils.mkpath('./install_files/directory')
    sleep(1)
    File.open('./install_files/file1.txt', 'w') { |f| f.write('Hello World') }
    File.open('./install_files/directory/file2.txt', 'w') { |f| f.write('Hello World') }
  end

  desc "Generate an installation msi file"
  task :installation => [:create_installation_files] do	  
    Wix.install_path = WIX_TOOLSET_ROOT

    installation_files = Dir.glob('./install_files/**/*')
    Wix.make_installation("./example.msi",  
      { 
	    manufacturer: 'Company', version: "1.0.0", 
	    product_code: '{69d12c6c-63be-43e4-92ff-e31ec3c86dc0}', 
	    upgrade_code: '{a62c35a7-6a6d-4392-822b-f6aca7eef88b}', 
	    files: installation_files
	  } 
	)
  end

  task :mergemodule => [:create_installation_files] do
    installation_files = Dir.glob('./install_files/**/*')
  
    Wix.install_path = WIX_TOOLSET_ROOT
    Wix.make_mergemodule('./example.msm', installation_files)
  end

  task :default => [:installation]
```

## License
Copyright 2013-2014 Kevin Marshall

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

