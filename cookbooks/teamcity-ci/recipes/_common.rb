if node.platform_family =="rhel"
  execute "install epel repo and devlopment tools" do
    command "rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm;yum -y groupinstall 'Development Tools'"
    not_if { ::File.exists? "/etc/yum.repos.d/epel.repo" }
  end
elsif node.platform_family == "debian"
  ['libsqlite3-dev','postgresql-client-9.4','openssl','libssl-dev','libreadline6-dev','libxml2','libxml2-dev',
   'libxslt1.1','libxslt1-dev','libpcre3-dev',"sqlite3","libsqlite3-dev","libqt4-dev",
   "imagemagick","libmagickwand-dev","nodejs","npm","libmysqlclient-dev","build-essential"].each do |pkg|
     package pkg
   end
end

package 'git'
include_recipe "rbenv"
include_recipe "rbenv::ruby_build"
node["ci"]["ruby_version"].each do | ruby|
  rbenv_ruby ruby

  node['ci']['ruby_gems'].each do |gem|
    rbenv_gem gem do
      ruby_version ruby
    end
  end
end

execute "set localtime to calcutta" do
  command "ln -sf /usr/share/zoneinfo/Asia/Calcutta localtime"
end

_git_setup "setup git" do
  user "teamcity"
  group "teamcity"
  user_home node["teamcity"]["home"]
  apps ["ecom-platform","ecom-docs","infra"]
end

knife_setup "ci"  do
  chef_user "teamcity"
  chef_group "teamcity"
  knife_user "teamcity"
  chef_dir node["teamcity"]["home"]
end

execute "download private key" do
  command "su - teamcity -c 'aws s3 cp #{node["ci"]["bucket"]}/deploy_keys/teamcity-ssh  #{node["teamcity"]["home"]}/.ssh/id_rsa;chmod 400  #{node["teamcity"]["home"]}/.ssh/id_rsa'"
end


include_recipe "nginx"

begin
  r = resources(:package => "nginx")
  r.version node["nginx"]["version"]
  r.notifies :reload, 'ohai[reload_nginx]', :immediately
  r.not_if 'which nginx'
end

directory "/var/lib/nginx" do
  user "teamcity"
  group "www-data"
end

# nginx.conf.erb should be in cookbook which is calling this definition
template "/etc/nginx/conf.d/teamcity.conf" do
  source "nginx.conf.erb"
  user "teamcity"
  group "www-data"
  mode "400"
  notifies :reload, "service[nginx]"
end

include_recipe "java"
include_recipe "teamcity-ci::db_server"
