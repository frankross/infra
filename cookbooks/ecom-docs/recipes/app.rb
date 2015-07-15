app                              = "ecom-docs"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

_install_awscli

chef_config_path = Chef::Config['file_cache_path']

execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
end.run_action(:run)

secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
secret = `cat #{chef_config_path}/#{secret_file_name}`
settings = Chef::EncryptedDataBagItem.load("ecom-docs","settings",secret).to_hash[node.chef_environment]["environment_variables"]

app_environment_variables = {}
app_environment_variables.merge! node["ecom-docs"].environment_variables
app_environment_variables.merge! settings

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
  command "su - #{node.apps.user} -c 'aws s3 sync s3://#{node["ecom-docs"]["s3_bucket"]} #{app_location}/current/doc/api/v1'"
end
