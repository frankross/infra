#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "update" do
  command "apt-get -y update"
  action :nothing
end.run_action(:run)

include_recipe "base::_hostname"
include_recipe "base::users_manage"
include_recipe "ntp::default"
