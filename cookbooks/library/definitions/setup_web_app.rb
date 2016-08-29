define :setup_web_app do

  app           = params[:name]
  app_user      = "web" 
  app_group     = "web" 
  app_user_home = "/home/web"
  app_location  = params[:app_location]
#  app_service   = params[:app_service]

  user app_user do
    home "/home/#{app_user}"
    action :create
    manage_home true
    shell "/bin/bash"
    not_if "grep #{app_user} /etc/passwd"
    action :nothing
  end.run_action(:create)

 group 'sysadmin' do
   action :modify
   members 'web'
   append true
 end

  _git_setup "setup git" do
    user app_user
    group app_user
    user_home app_user_home
    apps [app]
  end


  execute "apt-get install -y build-essential"
  package "libsqlite3-dev"

  package 'git' do
    action :install
  end.run_action(:install)

  temp_dir = Chef::Config['file_cache_path']

  bash "downloading build_versions.yml" do
    code "su - root -c 'aws s3 cp #{node["s3_bucket"]}/sha_number.yml #{temp_dir}/'"
    action :nothing
  end.run_action(:run)

#  latest_sha   = YAML.load(File.read "#{temp_dir}/sha_number.yml")
  latest_sha   = YAML.load(File.read "#{temp_dir}/sha_number.yml")[node.chef_environment][app]["sha"]
  current_sha  = File.open("#{app_location}/current/.git/refs/heads/deploy", "r").read.delete!("\n") if Dir.exists?("#{app_location}/current")
  node.override["apps"]["latest_sha"] = latest_sha
  node.override["apps"]["current_sha"] = current_sha
  release_dir  = "#{app_location}/releases/#{latest_sha}"
  node.override["apps"]["release_dir"] = release_dir

  git release_dir do
    repository node[app]['vcs_address']
    revision node[app]['vcs_branch']
    action :checkout
    user app_user
    group app_group
    not_if { latest_sha == current_sha}
  end

  execute "delete older releases" do
    command "ls -lt | tail -n+$((#{node.apps.max_number_of_release_dirs}+2)) | awk '{print $9}' | xargs -I{} rm -rf #{node.apps.location}/releases/{}"
    cwd "#{node.apps.location}/releases"
  end

end
