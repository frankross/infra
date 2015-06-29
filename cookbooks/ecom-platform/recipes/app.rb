app                              = "ecom-platform"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

_install_awscli

setup_app "#{app}" do
  app_location app_location
  app_service app_service
end
