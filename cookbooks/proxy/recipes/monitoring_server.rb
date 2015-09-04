#
# Cookbook Name:: infra_essentials
# Recipe:: monitoring_server
# All rights reserved - Do Not Redistribute

include_recipe "datadog::dd-agent"

template "/etc/dd-agent/conf.d/http_check.py" do
  source "http.py.erb"
  owner "dd-agent"
  mode 0755
  variables(datadog_user: "@slack-infra" )
  action :create
end


datadog_monitor 'http_check' do
  instances node['datadog']['http_check']['instances']
end
