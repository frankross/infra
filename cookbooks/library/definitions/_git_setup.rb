define :_git_setup do
  user = params[:user]
  user_home = params[:user_home]
  apps = params[:apps]
  group = params[:group]

  directory "#{user_home}/.ssh" do
    user user
    group group
    mode 00755
  end.run_action(:create)

  _install_awscli "git-setup" do
    home user_home
    user user
  end

  apps.each do |app|
    execute "download private key" do
      command "su - #{user} -c 'aws s3 cp #{node["ci"]["bucket"]}/deploy_keys/#{app}  #{user_home}/.ssh;chmod 400 #{user_home}/.ssh/#{app}'"
    end.run_action(:run)
  end

  template "#{user_home}/.ssh/config" do
    source "ssh/config.erb"
    variables(apps: apps)
    mode "644"
    user user
    group group
    cookbook 'library'
  end.run_action(:create)
end
