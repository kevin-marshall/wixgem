# Wixgem
Ruby gem to facilitate automate constructing Windows installation files 
with the Wix Toolset.

## Installation
Wixgem can be installed by the single command: *gem install wixgem*

## Example Usage
#### Dependencies
The [WiX Toolset](http://wixtoolset.org) must be installed.

#### Installation
```ruby
require 'wixgem'
	
Wixgen::Wix.make_installation('Product.msi', ['rakefile.rb']])

Wixgen::Wix.make_installation('Product.msi', {product_name: 'productname',
                              version: '1.1.0.0'
                              upgrade_code: '{1d5df00a-c18d-4897-95e6-8c936dd19647}',
                              files: ['rakefile.rb'] }	
					   
Wixgen::Wix.make_installation('Product.msi', {modify_file_paths: {/\Atest_files\// => ''}, 
                              files: Dir.glob("test_files/**/*")})					   
```
  
#### Merge Module
```ruby
require 'wixgem'
	
WIX_TOOLSET_ROOT='path to root of Wix toolset'
Wixgen::Wix.make_mergemodule('Product.msm', ['rakefile.rb']])

```
An example rakefile.rb is included in the example directory of the gem.

## Documenation

Wixgem will generate an installation or merge module from an array of files. The Wixgem also supports a 
small set of optional arguments allowing the developer to customize the generated installation file. 

#### Optional input hash keys
* **product_name**: String specifing the product name of the installation.
* **manufacturer**: String specifing the manufacturer of the installation.
* **version**:      String specifing the version of the installation. i.e. '1.1.0.0'
* **product_code**: Is a string GUID used to uniquely identify each version of the installation. i.e.' {4528ae5a-c7fa-40a6-a70e-ac8135f1114c}'
* **upgrade_code**: Is a string GUID used to identify all installed versions of the product. It is important to 
                 properly address the upgrade code before shipping the first version of a product.
* **files**:        A string array of file paths to be added to the installation.
* **modify_file_paths**: A hash of regex objects to replacement string pairs. The regular expressions are applied to
                      the file paths allowing the developer to modify the relative location of the files in the installation.
* **has_vb6_files**: Required if installation contains any ocx's or dll's compiled with Visual Basic 6.
* **remove_existing_products**: A boolean value. If the value is true the installation will remove the previous 
                                installation of the product before installing the product.
* **all_users**: String value perUser or perMachine. The default is perUser.
* **suppress_registry_harvesting** Suppress's heat's registry harvesting. Can fix the Runtime Error E6034.		 
* **suppress_COM_elements** Suppress COM elements, Heat's -scom
* **installer_version** Represents the minimum version of the Windows installer required to install
                        this package. The default version is 4.5 i.e. NETFRAMEWORK45
* **requires_netframework** Tests to see if the require netframework version is installed on the machine. The
                            associated value specifies the netframework version. The net framework strings can
                            be found at http://wixtoolset.org/documentation/manual/v3/customactions/wixnetfxextension.html							
* **binary_table**  Key is associated with an array of hashes specifying a file and a binary key to place into the 
                    binary table.
* **custom_actions** Key is associated with an array of hashes specifying the arguments for custom actions.
* ** shortcuts ** Key is associated with a hash specifying arguments to create shortcuts. Currently, 
                  the only supported shortcut is a desktop shortcut.
* ** extensions ** Key is associated with a hash to register executables with extensions.
* ** com_self_register ** Is a key associated with an array of files com dll's/exe's to mark for self
                          registration
* ** ignore_files ** Is a key associated with an array of files to ignore when generating the installation. This
                     key is useful for having files copied to the installation folder to generating the installation,
					 but not adding the files to the installation. An example of usage is I had a COM dll causing 
					 heat some problems, so I needed to add the dependency dll's to the install directory so heat could
					 harvest the com registry entries, but heat was choking on adding the support dll to the 
					 installation. Thus, I was able to create a merge module for the COM dll and another merge module for
					 the supporting dlls.
* **debug**: Boolean value. If debug is true the Product's wxs file and a log file are copied
             to the same directory as the output msi file. If you are familiar with WiX this can helpful
			 if there is a problem.      

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
