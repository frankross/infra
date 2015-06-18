#
# Cookbook Name:: nat_server
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iptables::default"

iptables_rule 'ssh' do
  action :enable
end

iptables_rule 'nat' do
  action :enable
end

case node.platform_family
when "debian"
  network_init_service = "networking"
when "rhel"
  network_init_service = "network"
end

service network_init_service do
  action :enable
end

execute "adding ip4 forward" do
  command "sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf;echo 1 > /proc/sys/net/ipv4/ip_forward"
  notifies :restart, "service[#{network_init_service}]", :delayed
  not_if "cat /etc/sysctl.conf | grep net.ipv4.ip_forward |grep 1"
  user "root"
end
