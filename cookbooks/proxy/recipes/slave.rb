include_recipe "proxy::_common"

peers =  search(:node,"run_list:recipe\\[proxy\\:\\:master\\] AND chef_environment:#{node.chef_environment}").map{|m| m.ipaddress}

require 'byebug'
byebug

template '/etc/keepalived/keepalived.conf' do
  source 'keepalived.conf.erb'
  mode '644'
  variables(
    state: 'SLAVE',
    peers: peers,
    priority: 98
  )
  action :create
  notifies :restart, "service[keepalived]"
end

process_check "proxy" do
  process node["monitoring"]["processes"]
end
