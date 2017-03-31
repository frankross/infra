#
# Cookbook Name:: delayed_job
# Recipe:: default
#
app                                  = "ecom-platform"
app_location                         = node.apps.location
app_user                             = node.apps[:user]
app_group                            = node.apps[:group]

node.override["apps"]["init_script_name"] = "dj"
node.default["monitoring"]["processes"]  = [{name: 'delayed_job', search_string: ['delayed_job']}]

include_recipe "ecom-platform::_common"

app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables

link_release "ecom-platform" do
  app_location node.apps.location
  app_service node.apps.init_script_name
end

execute "create delayed job bin" do
  command "bundle exec rails generate delayed_job"
  env Hash[app_environment_variables.merge("RAILS_ENV" => "production").map{|key, value| [ key.to_s, value.to_s ]}]
  cwd "#{app_location}/current"
  not_if { ::File.exists?("#{app_location}/current/bin/delayed_job") }
end

worker_queue_map = {
  :sms => 2,
  :algolia => 2,
  :notifications => 1,
  :customer_report_download => 1
}

queue_config = ""
worker_queue_map.each do |key, value|
  queue_config << " --pool=#{key}:#{value}"
end

template "/etc/init.d/dj" do
  source "dj/dj.erb"
  variables(app: app,
            user: app_user,
            group: app_group,
            queue_config: queue_config,
            env: node.chef_environment,
            project_path: app_location)
  mode "775"
  owner app_user
  group app_group
  notifies:restart, "service[dj]", :delayed
end

service "dj" do
  supports status: true, start: true, stop: true, restart: true
  action :enable
end

['libxslt1.1','libxslt1-dev','libpcre3-dev',"imagemagick","libmagickwand-dev","build-essential"].each do |pkg|
  log 'message' do
    message "Installing package #{pkg}"
    level :debug
  end
  package pkg
end

node.override["datadog"]["tags"].push("delayed_job")

process_check "ecom-platform" do
  process node["monitoring"]["processes"]
end

papertrail "app" do
  log_file ["#{app_location}/current/log/*.log","#{app_location}/shared/log/*.log","/var/log/syslog"]
end

_logrotate "app_logs" do
    path "#{app_location}/shared/log/*.log"
  end

monit "dj"
