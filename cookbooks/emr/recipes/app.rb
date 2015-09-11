app                              = "emr"
app_service                      = node["apps"]["init_script_name"]
app_location                     = node.apps.location


_install_awscli

chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret                    = File.read "#{chef_config_path}/#{secret_file_name}"
settings                  = Chef::EncryptedDataBagItem.load(app,"settings",secret).to_hash[node.chef_environment]["environment_variables"]

app_environment_variables = {}
node.default["emr"].environment_variables["API_HOST"]="https://#{node["emr"]["cname"]}"
node.default["emr"].environment_variables["MAILER_DEFAULT_HOST"]="https://#{node["emr"]["cname"]}"
node.default["emr"].environment_variables["MAILER_DOMAIN"]="https://#{node["emr"]["cname"]}"
app_environment_variables.merge! node["emr"].environment_variables
app_environment_variables.merge! settings

['libxslt1.1','libxslt1-dev','libpcre3-dev',"imagemagick","libmagickwand-dev","build-essential"].each do |pkg|
  log 'message' do
    message "Installing package #{pkg}"
    level :debug
  end
  package pkg
end

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

_asset_precompile app do
  app_location node.apps.location
  environment_variables app_environment_variables
end

_app_servers "#{app}" do
  app_location app_location
  app_service app_service
end

link_release "emr" do
  app_location node.apps.location
  app_service app_service
end
