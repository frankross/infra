#This recipe is to give user based ssh access


users_manage "sysadmin" do
  group_id 1200
  action [ :create ]
end

users_manage node.chef_environment do
  group_id 1201
  action [ :create ]
end


node.default['authorization']['sudo']['passwordless'] = true
node.override['authorization']['sudo']['groups']= [node.chef_environment, "sysadmin"]
include_recipe "sudo"
