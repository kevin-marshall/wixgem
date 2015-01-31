require 'open3'
require 'hash'

module Wixgem

class Command < Hash
  def initialize(cmd, options=nil)
   self[:output] = ''
   self[:error] = ''
   self[:exit_code] = ''
   self[:ignore_exit_code] = false
   self[:debug] = false
   self[:quiet] = false

   self[:command]=cmd
   options.each { |key, value| self[key] = value} unless(options.nil?)
  end
  
  def execute
    begin
	  puts self[:command] unless(self[:quiet])
      self[:output],self[:error], self[:exit_code] = Open3.capture3(self[:command])
      self[:exit_code]=self[:exit_code].to_i
	  
	  if(self[:debug])
	    puts "output: #{self[:output]}"
	    puts "error: #{self[:error]}"
	    puts "exit_code: #{self[:exit_code]}"
	  end
	rescue Exception => e
	  self[:error] = "Exception: " + e.to_s
	  self[:exit_code]=1
	end
	
	if((self[:exit_code] != 0) && !self[:ignore_exit_code])
	  exception_text = self[:error]
	  exception_text = self[:output] if(self[:error].empty?)
	  raise exception_text 
	end
  end
end

end