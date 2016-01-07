#
# Cookbook Name:: proxy
# Recipe:: _haproxy
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
  servers =  search(:node,"run_list:recipe\\[#{server[:name]}\\:\\:app\\] AND chef_environment:#{node.chef_environment}")
  server.merge!(backend_servers:  servers)
end

directory "/etc/haproxy/certs" do
  mode 00744
  action :create
  recursive true
end

chef_config_path = Chef::Config['file_cache_path']
secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
execute "download secret key" do
  command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
  not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
end.run_action(:run)

secret = File.read "#{chef_config_path}/#{secret_file_name}"
key    = Chef::EncryptedDataBagItem.load("haproxy","keys",secret).to_hash["key"]

file "/etc/haproxy/certs/frankross.pem" do
  content key
  mode 00400
  action :create
  notifies :restart, "service[haproxy]"
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy/haproxy.cfg.erb"
  mode "644"
  variables(
    frontend_servers: frontend_servers,
    stats_user: user,
    stats_password: password,
    env: node.chef_environment,
    key: "frankross"
  )
  action :create
  notifies :restart, "service[haproxy]", :delayed
end

template "/etc/rsyslog.d/haproxy_log.conf" do
  source "haproxy/haproxy.logconf.erb"
  mode "644"
  action :create
  notifies :restart, "service[rsyslog]", :delayed
end

template '/etc/dd-agent/conf.d/haproxy.yaml' do
  source 'datadog/haproxy.yaml.erb'
  owner 'dd-agent'
  group 'root'
  variables(
    :eip=> node.proxy.aws.eip,
    :username => user,
    :password => password
  )
end
node.override["datadog"]["tags"].push("haproxy")

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

_logrotate "haproxy" do
  path "/var/log/haproxy/*"
end
