app                              = "ecom-platform"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

_install_awscli

include_recipe "ecom-platform::_common"

app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables

_asset_precompile app do
  app_location node.apps.location
  environment_variables app_environment_variables
end

_app_servers "#{app}" do
  app_location app_location
  app_service app_service
end
