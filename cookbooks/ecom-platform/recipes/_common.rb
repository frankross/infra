app                              = "ecom-platform"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret                    = File.read "#{chef_config_path}/#{secret_file_name}"
settings                  = Chef::EncryptedDataBagItem.load(app,"settings",secret).to_hash[node.chef_environment]["environment_variables"]

app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables
app_environment_variables.merge! settings
node.set["ecom-platform"].environment_variables = app_environment_variables

setup_app "#{app}" do
  app_location app_location
  app_service app_service
  environment_variables app_environment_variables
end

_configure_postgres_client app do
  app_location app_location
  app_service app_service
end
