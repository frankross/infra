app                              = "ecom-docs"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

_install_awscli

app_environment_variables = {}
app_environment_variables.merge! node["ecom-docs"].environment_variables

setup_app "#{app}" do
  app_location app_location
  app_service app_service
  environment_variables app_environment_variables
end

_asset_precompile app do
  app_location node.apps.location
  environment_variables app_environment_variables
end

_app_servers "#{app}" do
  app_location node.apps.location
  app_service app_service
end
