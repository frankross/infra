#
# Cookbook Name:: proxy
# Recipe:: _keepalived
#
# Copyright (C) 2014 ajey
#
# All rights reserved - Do Not Redistribute
#
["iproute","ipvsadm","libnl-3-200","libnl-genl-3-200","libsensors4","libsnmp30"].each do |pkg|
  package pkg
end

package "libssl-dev"

temp_dir = Chef::Config['file_cache_path']

execute "deb_install_keepalived" do
  command "aws s3 cp s3://#{node.s3_bucket}/keepalived/keepalived_1.2.9-1_amd64.deb #{temp_dir};dpkg -i #{temp_dir}/keepalived_1.2.9-1_amd64.deb"
  cwd Chef::Config['file_cache_path']
  not_if "dpkg -l | grep ruby"
end

service "keepalived" do
  service_name "keepalived"
  supports :restart => true
  action [ :enable, :start ]
end

aws_creds = data_bag_item("aws", "awscli")

template "/etc/keepalived/vrrp.sh" do
  source "vrrp.sh.erb"
  mode "755"
  variables(access_key: aws_creds['access_key'],
            secret_key: aws_creds['secret_key'],
            eip: node.proxy.aws.eip,
            region: aws_creds['region']
           )
  action :create
  notifies :restart, "service[keepalived]"
end
