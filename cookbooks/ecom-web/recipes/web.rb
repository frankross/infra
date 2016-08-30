app                              = "ecom-web"
app_location                     = node.apps.location
app_user			 = "web"
app_group 			 = "web"
release_dir 			 = "/srv/www/ecom-web/current"

_install_awscli

chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret                    = File.read "#{chef_config_path}/#{secret_file_name}"


setup_web_app "#{app}" do
  app_location app_location
end

link_release_web "ecom-web" do
  app_location node.apps.location
end

bash 'Execute node commands' do 
  user 'web'
  cwd  '/srv/www/ecom-web/current'
  environment ({ 'HOME' => '/home/web' })
  code <<-EOH
  HOME='/home/web'
  sudo npm install
  sudo bower install --allow-root
  gulp stage-build
  EOH
end
