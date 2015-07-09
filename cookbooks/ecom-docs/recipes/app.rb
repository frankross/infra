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

execute "sync with s3" do
  cwd "#{app_location}/current"
  command "su - #{node.apps.user} -c 'aws s3 sync s3://#{node["ecom-docs"]["s3_bucket"]} ./doc/api/v1'"
end