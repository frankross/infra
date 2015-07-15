#
# Cookbook Name:: delayed_job
# Recipe:: default
#
app          = "ecom-platform"
app_location = node.apps.location
app_user     = node.apps[:user]
app_group    = node.apps[:group]

include_recipe "ecom-platform::app"

chef_config_path = Chef::Config['file_cache_path']

secret_file_name =  node["databag"]["secret_location"].split("/")[-1]

execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret = `cat #{chef_config_path}/#{secret_file_name}`
settings = Chef::EncryptedDataBagItem.load(app,"settings",secret).to_hash[node.chef_environment]["environment_variables"]
app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables
app_environment_variables.merge! settings

execute "create delayed job bin" do
  command "bundle exec rails generate delayed_job"
  env Hash[app_environment_variables.merge("RAILS_ENV" => "production").map{|key, value| [ key.to_s, value.to_s ]}]
  cwd "#{app_location}/current"
  not_if { ::File.exists?("#{app_location}/current/bin/delayed_job") }
end

worker_counts = {'default' => 1, 'slow' => 1, 'image' => 1}
queues = worker_counts.keys.join(",")
count = worker_counts.values.inject(&:+)

template "/etc/init.d/dj" do
  source "dj/dj.erb"
  variables(app: app,
            user: app_user,
            queues: queues,
            count: count,
            group: app_group,
            env: node.chef_environment,
            project_path: app_location)
  mode "775"
  owner app_user
  group app_group
end

service "dj" do
  supports status: true, start: true, stop: true, restart: true
  action :enable
  subscribes :restart, "service[puma]", :delayed
end
