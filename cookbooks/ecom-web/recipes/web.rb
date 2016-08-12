app                              = "ecom-web"
app_location                     = node.apps.location
app_user = "web"
app_group = "web"
release_dir = "/srv/www/ecom-web/current"

#node.default["monitoring"]["processes"]  = [{name: 'puma', search_string: ['puma']},{name: 'nginx', search_string: ['nginx']}]
_install_awscli

chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret                    = File.read "#{chef_config_path}/#{secret_file_name}"
#settings                  = Chef::EncryptedDataBagItem.load(app,"settings",secret).to_hash[node.chef_environment]["environment_variables"]

#app_environment_variables = {}
#node.default["emr"].environment_variables["API_HOST"]="#{node["emr"]["cname"]}"
#node.default["emr"].environment_variables["MAILER_DEFAULT_HOST"]="#{node["emr"]["cname"]}"
#node.default["emr"].environment_variables["MAILER_DOMAIN"]="#{node["emr"]["cname"]}"
#app_environment_variables.merge! node["emr"].environment_variables
#app_environment_variables.merge! settings

['libxslt1.1','libxslt1-dev','libpcre3-dev',"imagemagick","libmagickwand-dev","build-essential"].each do |pkg|
  log 'message' do
    message "Installing package #{pkg}"
    level :debug
  end
  package pkg
end

setup_web_app "#{app}" do
  app_location app_location
 # app_service app_service
  #environment_variables app_environment_variables
end

#_configure_postgres_client app do
#  app_location app_location
#  app_service app_service
#  environment_variables app_environment_variables
#end

#_asset_precompile app do
#  app_location node.apps.location
#  environment_variables app_environment_variables
#end

#_app_servers "#{app}" do
#  app_location app_location
#  app_service app_service
#end

#process_check "emr" do
 # process node["monitoring"]["processes"]
#end

link_release_web "ecom-web" do
  app_location node.apps.location
#  app_service app_service
end

bash 'Execute node commands' do 
  user 'web'
  cwd  '/srv/www/ecom-web/current'
  environment ({ 'HOME' => '/home/web' })
  code <<-EOH
  HOME='/home/web'
  sudo npm install
  sudo bower install --allow-root
  gulp build 
  gulp styles 
  gulp scripts
  EOH
end
#  execute "npm install" do
#    command "npm install"
#    user app_user
##    group app_group
#    cwd release_dir
#  end
#  execute "bower install" do
#    command " bower install --allow-root"
#    user app_user
#    group app_group
#    cwd release_dir
#  end

#  execute "gulp install" do
#    command "gulp build && gulp styles && gulp scripts"
#    user app_user
#    group app_group
#    cwd release_dir
#  end
