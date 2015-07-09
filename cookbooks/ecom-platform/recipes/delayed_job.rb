#
# Cookbook Name:: delayed_job
# Recipe:: default
#
app          = "ecom-platform"
app_location = node.apps.location
app_user     = node.apps[:user]
app_group    = node.apps[:group]

include_recipe "ecom-platform::app"
app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables

execute "create delayed job bin" do
  command "bundle exec rails generate delayed_job"
  env Hash[app_environment_variables.merge("RAILS_ENV" => "production").map{|key, value| [ key.to_s, value.to_s ]}]
  cwd "#{app_location}/current"
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
end