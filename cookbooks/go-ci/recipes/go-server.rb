include_recipe "go::server"
include_recipe "go-ci::_common"

template "/etc/go/cruise-config.xml" do
  source "config.xml.erb"
  variables pipelines: node["ci"]["jobs"]
  user "go"
  group "go"
  mode "644"
  notifies :restart,"service[go-server]",:delayed
end
