if node.platform_family =="rhel"
  execute "install epel repo and devlopment tools" do
    command "rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm;yum -y groupinstall 'Development Tools'"
    not_if { ::File.exists? "/etc/yum.repos.d/epel.repo" }
  end
elsif node.platform_family == "debian"
  ['openssl','libssl-dev','libreadline6-dev','libxml2','libxml2-dev',
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
