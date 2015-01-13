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
	
WIX_TOOLSET_ROOT='path to root of Wix toolset'
Wix.make_installation('Product.msi', ['rakefile.rb']])

Wix.make_installation('Product.msi', {product_name: 'productname',
                       version: '1.1.0.0'
                       upgrade_code: '{1d5df00a-c18d-4897-95e6-8c936dd19647}',
                       files: ['rakefile.rb'] }	
					   
Wix.make_installation('Product.msi', {modify_file_paths: {/\Atest_files\// => ''}, files: Dir.glob("test_files/**/*")})					   
```
  
#### Merge Module
```ruby
require 'wixgem'
	
WIX_TOOLSET_ROOT='path to root of Wix toolset'
Wix.make_mergemodule('Product.msi', ['rakefile.rb']])

```
An example rakefile.rb is included in the example directory of the gem.

## Documenation

Wixgem will generate an installation or merge module from an array of files. The Wixgem also supports a 
small set of optional arguments allowing the developer to customize the generated installation file. 

#### Optional input hash arguments
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
* **remove_existing_products**: A boolean value. If the value is true the installation will remove all existing 
                             installations of the product before installing the product.
                  

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
