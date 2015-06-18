#
# Cookbook Name:: vpn
# Recipe:: default
#
# Copyright (C) 2014 Shobhit
#
# All rights reserved - Do Not Redistribute

include_recipe "openvpn::default"

begin
  r = resources(:service => "openvpn")
  r.action "enable"
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn "could not find service to override!"
end

openvpn_conf 'server' do
  port node['openvpn']['port']
  proto node['openvpn']['proto']
  type node['openvpn']['type']
  local node['openvpn']['local']
  routes node['openvpn']['routes']
  script_security node['openvpn']['script_security']
  key_dir node['openvpn']['key_dir']
  key_size node['openvpn']['key']['size']
  subnet node['openvpn']['subnet']
  netmask node['openvpn']['netmask']
  user node['openvpn']['user']
  group node['openvpn']['group']
  log node['openvpn']['log']
  dhcp_dns node["dns"]["server"]
  notifies :restart, 'service[openvpn]', :delayed
end
