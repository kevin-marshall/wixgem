require 'open3'

module Wixgem

class Command < Hash
  def initialize(cmd)
   self[:command]=cmd
   self[:output] = ''
   self[:error] = ''
   self[:exit_code] = ''
   self[:ignore_exit_code] = false
   self[:debug] = false
  end
  
  def execute
    begin
	  puts "command: #{self[:command]}" if(self[:debug])
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
	  
	  usr_msg = "Command exit code: #{self[:exit_code]}"
	  usr_msg = "#{usr_msg}\nCommand exception: #{exception_text}" unless(exception_text.empty?)
	  raise usr_msg
	end
  end
end

end