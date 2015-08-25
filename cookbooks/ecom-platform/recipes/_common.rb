app                              = "ecom-platform"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location

_install_awscli

aws_creds = data_bag_item("aws", "awscli")
chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret                    = File.read "#{chef_config_path}/#{secret_file_name}"
settings                  = Chef::EncryptedDataBagItem.load(app,"settings",secret).to_hash[node.chef_environment]["environment_variables"]

memcached_servers =  search(:node,"run_list:recipe\\[emami_memcached\\] AND chef_environment:#{node.chef_environment}").map{|m| m.ipaddress}
node.override["ecom-platform"].environment_variables["AWS_ACCESS_KEY_ID"]=aws_creds["access_key"]
node.override["ecom-platform"].environment_variables["AWS_SECRET_ACCESS_KEY"]=aws_creds["secret_key"]
node.override["ecom-platform"].environment_variables["MEMCACHE_SERVERS"]=memcached_servers
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
  environment_variables app_environment_variables
end
