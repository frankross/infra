app                              = "ecom-platform"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

node.default["monitoring"]["processes"]  = [{name: 'puma', search_string: ['puma']},{name: 'nginx', search_string: ['nginx']}]

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

process_check "ecom-platform" do
  process node["monitoring"]["processes"]
end

link_release "ecom-platform" do
  app_location node.apps.location
  app_service app_service
end
