#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "base::_hostname"
include_recipe "base::users_manage"
include_recipe "base::dd_monitored"
