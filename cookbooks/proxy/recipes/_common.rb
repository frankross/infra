#
# Cookbook Name:: proxy
# Recipe:: _common
#
# Copyright (C) 2013 Grasshopper LLC
#
# All rights reserved - Do Not Redistribute
#

_install_awscli "install awscli" do
  home "/root"
end

include_recipe "proxy::_haproxy"
include_recipe "proxy::_secondary_ip"
include_recipe "proxy::_keepalived"
include_recipe "proxy::monitoring_server"
