define :_git_setup do
  user = params[:user]
  user_home = params[:user_home]
  apps = params[:apps]

  directory "#{user_home}/.ssh" do
    user user
  end.run_action(:create)

  _install_awscli "ecom-platform" do
    home user_home
    user user
  end

  apps.each do |app|
    execute "download private key" do
      command "su - #{user} -c 'aws s3 cp #{node["ci"]["bucket"]}/deploy_keys/#{app}  ~/.ssh;chmod 400 ~/.ssh/#{app}'"
    end.run_action(:run)
  end

  template "#{user_home}/.ssh/config" do
    source "ssh/config.erb"
    variables(apps: apps)
    mode "644"
    user user
    cookbook 'library'
  end.run_action(:create)
end
