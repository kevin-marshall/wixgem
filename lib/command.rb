require 'open3'
require 'hash'

module Wixgem

class Command < Hash
  def initialize(cmd)
   self[:command]=cmd
   self[:output] = ''
   self[:error] = ''
   self[:exit_code] = ''
   self[:ignore_exit_code] = false
  end
  
  def execute
    begin
      self[:output],self[:error], self[:exit_code] = Open3.capture3(self[:command])
      self[:exit_code]=self[:exit_code].to_i
	rescue Exception => e
	  self[:error] = "Exception: " + e.to_s
	  self[:exit_code]=1
	end
	
	raise self[:error] unless((self[:exit_code] == 0) || self[:ignore_exit_code])
  end
end

end