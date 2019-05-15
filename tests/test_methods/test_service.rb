require 'win32/service'

def test_service(msi, wix_hash)
  wix_hash[:services].each do |service_app|
    service_name = service_app[:service][:name]
    assert(Win32::Service.exists?(service_name), "Service '#{service_name}' is not registered.")	  
  end
end