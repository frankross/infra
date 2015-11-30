include_recipe "proxy::_common"

peers =  search(:node,"run_list:recipe\\[proxy\\:\\:slave\\] AND chef_environment:#{node.chef_environment}").map{|m| m.ipaddress}

template '/etc/keepalived/keepalived.conf' do
  source 'keepalived.conf.erb'
  mode '644'
  variables(
    state: 'MASTER',
    peers: peers,
    priority: 101
  )
  action :create
  notifies :restart, "service[keepalived]"
end

process_check "proxy" do
  process node["monitoring"]["processes"]
end
