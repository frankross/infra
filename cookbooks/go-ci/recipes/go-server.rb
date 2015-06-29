user "go" do
  home "/var/go"
  action :create
  manage_home true
  shell "/bin/bash"
  not_if "grep go /etc/passwd"
  action :nothing
end.run_action(:create)

include_recipe "go::server"
include_recipe "go-ci::_common"

template "/etc/go/cruise-config.xml" do
  source "config.xml.erb"
  variables pipeline_group: node["ci"]["jobs"]
  user "go"
  group "go"
  mode "644"
  notifies :restart,"service[go-server]",:delayed
end
