include_recipe "datadog::dd-agent"
include_recipe "datadog::dd-handler"

cookbook_file "/etc/init.d/datadog-agent" do
  source "datadog/datadog_#{node.platform_family}.sh"
  mode "755"
  notifies :restart, "service[datadog-agent]", :delayed
end
