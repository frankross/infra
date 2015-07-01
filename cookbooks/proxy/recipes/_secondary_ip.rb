#
# Cookbook Name:: proxy
# Recipe:: _secondary_ip
#
# Copyright (C) 2014 vipul
#
# All rights reserved - Do Not Redistribute
#
aws_creds = data_bag_item(:aws, "awscli")
template "/usr/local/bin/secondary_ip.sh" do
  source "haproxy/secondary_ip.sh.erb"
  mode "755"
  variables(
    access_key: aws_creds['access_key'],
    secret_key: aws_creds['secret_key'],
    region: aws_creds['region']
  )
  action :create
  not_if "ls /etc/network/interfaces.d | grep eth0:1.cfg"
  notifies :run,"execute[run_assign_private_ip]", :immediately
end

execute "run_assign_private_ip" do
  command "/usr/local/bin/secondary_ip.sh"
  action :nothing
  notifies :run, "execute[remove_executable]", :delayed
end

execute "remove_executable" do
  command "rm /usr/local/bin/secondary_ip.sh"
  action :nothing
end
