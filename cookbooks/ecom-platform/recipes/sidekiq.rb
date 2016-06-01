#
# Cookbook Name:: delayed_job
# Recipe:: default
#
app                                  = "ecom-platform"
app_location                         = node.apps.location
app_user                             = node.apps[:user]
app_group                            = node.apps[:group]

node.override["apps"]["init_script_name"] = "sidekick"
#node.default["monitoring"]["processes"]  = [{name: 'delayed_job', search_string: ['delayed_job']}]

include_recipe "ecom-platform::_common"
#include_recipe "sidekiq::default"

app_environment_variables = {}
app_environment_variables.merge! node["ecom-platform"].environment_variables

link_release "ecom-platform" do
  app_location node.apps.location
  app_service node.apps.init_script_name

end
#sidekiq 'staging.frankross.in' do
#  concurrency 2
#  processes 2
#  queues 'job-queue' => 5, 'other-queue' => 1
#  directory '/srv/www/ecom-platform/current'
#  sidekiq_dir '/srv/www/ecom-platform/current'
#  rails_env 'staging'
#  owner app_user
#  group app_group
#end
 ##           queue_config: queue_config,

template "/etc/init.d/sidekick" do
  source "sidekick/sidekick.erb"
  variables(app: app,
            user: app_user,
            group: app_group,
            env: node.chef_environment,
            project_path: app_location)
  mode "775"
  owner app_user
  group app_group
  notifies:restart,  "service[sidekick]", :delayed
end

service "sidekick" do
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

#node.override["datadog"]["tags"].push("delayed_job")

#process_check "ecom-platform" do
#  process node["monitoring"]["processes"]
#end

papertrail "app" do
  log_file ["#{app_location}/current/log/*.log","#{app_location}/shared/log/*.log","/var/log/syslog"]
end

_logrotate "app_logs" do
    path "#{app_location}/shared/log/*.log"
  end

monit "sidekick"
