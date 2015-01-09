# Copyright 2013-2014 Kevin Marshall
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
Gem::Specification.new do |s|
	s.name			= 'wixgem'
	s.version		= "0.0.13"
	s.summary		= 'Simple Ruby interface to facilitate working with Wix Toolset'
	s.description	= 'Simple Ruby interface to facilitate creating and compiling windows installation files with the Wix Toolset.\n\nNote: This gem currently does not handle registration of COM objects or registry entries.'
	s.authors		= ["Kevin Marshall"]
	s.email			= 'KCCKSMarshall@gmail.com'
	#s.rubyforge_project = 'wixgem'
	s.homepage		= 'http://rubygems.org/gems/wixgem'
    s.required_ruby_version = '>= 1.9.1'
	s.files         = Dir["LICENSE","README.md","lib/**/*"]
	s.license       = 'Apache 2.0'
	s.require_path  = 'lib'
    s.add_development_dependency 'bundler', '~> 0'
	s.add_development_dependency 'rake', '~> 0'
	s.add_development_dependency 'rspec', '~> 0'
	s.add_development_dependency 'dev_tasks', '~> 0'
end