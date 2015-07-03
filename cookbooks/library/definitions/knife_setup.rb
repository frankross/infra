define :knife_setup do

  home_dir  = params[:chef_dir] || "/root"
  user      = params[:chef_user] || "root"
  group     = params[:chef_group] || "root"
  knife_user= params[:knife_user]

  directory "#{home_dir}/.chef" do
    recursive true
    owner user
    group group
    mode 00755
  end

  execute "download private key" do
    command "su - #{user} -c 'aws s3 cp #{node["ci"]["bucket"]}/deploy_keys/#{knife_user}.pem  #{home_dir}/.chef/;chmod 400 #{home_dir}/.chef/#{knife_user}.pem'"
  end.run_action(:run)

  aws_creds = data_bag_item(:aws, "awscli")

  template "/#{home_dir}/.chef/knife.rb" do
    owner user
    group group
    source "chef/knife.rb.erb"
    variables(
      chef_config_path: "#{home_dir}/.chef",
      chef_server_url:  node["chef_server"]["url"],
      user: knife_user,
      access_key: aws_creds["access_key"],
      secret_key: aws_creds["secret_key"]
    )
    cookbook "library"
  end
end
