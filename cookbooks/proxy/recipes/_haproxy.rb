#
# Cookbook Name:: proxy
# Recipe:: _haproxy
#
# Copyright (C) 2013 Grasshopper LLC
#
# All rights reserved - Do Not Redistribute
#

execute "sudo apt-add-repository ppa:vbernat/haproxy-1.5;sudo apt-get update"
package 'haproxy'

user 'haproxy' do
  not_if "grep haproxy /etc/passwd"
end

service "haproxy" do
  service_name "haproxy"
  supports :restart => true
  action [ :enable]
end

service "rsyslog" do
  service_name "rsyslog"
  supports :restart => true
  action [ :enable, :start ]
end

haproxy_creds = data_bag_item(:haproxy, "credentials")
user =  haproxy_creds['user']
password =  haproxy_creds['password']

frontend_servers = node.proxy.frontend_servers.dup
frontend_servers.each do |server|
  servers =  search(:node,"run_list:recipe\\[#{server[:name]}\\:\\:*\\] AND chef_environment:#{node.chef_environment}")
  server.merge!(backend_servers:  servers)
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy/haproxy.cfg.erb"
  mode "644"
  variables(
    frontend_servers: frontend_servers,
    stats_user: user,
    stats_password: password,
    env: node.chef_environment,
  )
  action :create
  notifies :restart, "service[haproxy]", :delayed
end

directory "/etc/haproxy/errors" do
  action :create
end
template "/etc/haproxy/errors/503.html" do
  source "haproxy/haproxy_503.html.erb"
  mode "644"
  action :create
end

include_recipe "iptables::default"

iptables_rule 'http' do
  action :enable
end

iptables_rule 'https' do
  action :enable
end
