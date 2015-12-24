require 'securerandom'

module Wixgem

def temp_directory
	tmp_file = "#{ENV['TEMP'].gsub(/\\/,'/')}/#{SecureRandom.hex}"
	FileUtils.mkpath(tmp_file)
	begin
		yield tmp_file
	rescue Exception => e
	  raise e
	ensure
	  sleep(0.5)
	  FileUtils.rm_rf(tmp_file)
	end
end

end
