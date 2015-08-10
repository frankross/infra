node.automatic_attrs["fqdn"] = "#{node.name}.emami.vpc"
node.automatic_attrs["hostname"] = "#{node.name}"

if node['platform_family']=="rhel"
  template "/etc/sysconfig/network" do
    source 'centos/network.erb'
  end
elsif node['platform_family']=="debian"
  execute "change hostname" do
    command "echo #{node.name}.emami.vpc > /etc/hostname"
    not_if "hostname -f | grep #{node.name}.emami.vpc"
  end
end

execute "networking restart" do
  command "/etc/init.d/networking restart; hostname #{node.name}.emami.vpc"
  not_if "hostname -f | grep #{node.name}.emami.vpc"
end

