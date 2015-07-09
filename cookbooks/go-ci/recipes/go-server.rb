user "go" do
  home "/var/go"
  action :create
  manage_home true
  shell "/bin/bash"
  action :nothing
end.run_action(:create)

include_recipe "go::server"
include_recipe "go-ci::_common"

ses_creds = data_bag_item("aws", "ses")

template "/etc/go/cruise-config.xml" do
  source "config.xml.erb"
  variables(
    pipeline_group: node["ci"]["jobs"],
    aws_creds: ses_creds
  )
  user "go"
  group "go"
  mode "644"
  notifies :restart,"service[go-server]",:delayed
end
