define :setup_app do

  app           = params[:name]
  app_user      = node.apps[:user]
  app_group     = node.apps[:group]
  app_user_home = "/home/#{node.apps[:user]}"
  app_location  = params[:app_location]
  app_service   = params[:app_service]

  user app_user do
    home "/home/#{app_user}"
    action :create
    manage_home true
    shell "/bin/bash"
    not_if "grep #{app_user} /etc/passwd"
    action :nothing
  end.run_action(:create)

  _git_setup "setup git" do
    user app_user
    group app_user
    user_home app_user_home
    apps [app]
  end

  ['libxml2-dev','libxslt1-dev','libpcre3-dev',"libqt4-dev","zlib1g-dev","build-essential","libpq-dev","libpq5","nodejs"].each do |pkg|
    package pkg
  end

  ["releases","shared/gems", "/shared/config","/shared/pids","/shared/sockets"].each do |dir|
    directory "#{app_location}/#{dir}" do
      recursive true
      owner app_user
      group app_group
      mode 00755
    end
  end

  execute "apt-get install -y build-essential"
  package "libsqlite3-dev"

  package 'git' do
    action :install
  end.run_action(:install)

  latest_sha   = `su - #{app_user} -c "git ls-remote #{node[app]['vcs_address']} --heads #{node[app]['vcs_branch']}" | awk '{print $1}'`.split("\n")[0]
  current_sha  = File.open("#{app_location}/current/.git/refs/heads/deploy", "r").read.delete!("\n") if Dir.exists?("#{app_location}/current")

  git "#{app_location}/releases/#{latest_sha}" do
    repository node[app]['vcs_address']
    revision node[app]['vcs_branch']
    action :checkout
    user app_user
    group app_group
    notifies :restart, "service[#{app_service}]", :delayed
    not_if { latest_sha == current_sha}
  end

  execute "delete older releases" do
    command "ls -lt | tail -n+$((#{node.apps.max_number_of_release_dirs}+2)) | awk '{print $9}' | xargs -I{} rm -rf #{node.apps.location}/releases/{}"
    cwd "#{node.apps.location}/releases"
  end

  link "#{app_location}/current" do
    to "#{app_location}/releases/#{latest_sha}"
    user app_user
    group app_group
    not_if { latest_sha == current_sha}
  end

  link "#{app_location}/current/gems" do
    to "#{app_location}/shared/gems"
    user app_user
    group app_group
  end

  link "#{app_location}/shared/log" do
    to "#{app_location}/current/log"
    user app_user
    group app_group
  end

  execute "ruby-install" do
    command "aws s3 cp #{node["ruby"]["s3_location"]} ./;dpkg -i *.deb"
    cwd Chef::Config['file_cache_path']
    not_if "dpkg -l | grep ruby"
  end

  execute "install bundler" do
    command "gem install bundler"
    not_if "which bundle"
  end

  execute "bundle install" do
    command "PATH=#{node.ruby.bin_location}:$PATH bundle install --path gems"
    user app_user
    group app_group
    cwd "#{app_location}/current"
  end

  template "/etc/default/#{app}.conf" do
    source "apps/app.conf.erb"
    owner app_user
    group app_group
    cookbook 'library'
    variables :environment_variables => params[:environment_variables]
    notifies :restart, "service[#{app_service}]", :delayed
    only_if { params[:environment_variables] }
  end
end
