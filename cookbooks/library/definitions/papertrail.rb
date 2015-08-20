define :papertrail do
  app_name = params[:name]
  log_file = params[:log_file]

  package 'build-essential'

  gem_package 'remote_syslog' do 
    action :install
  end

  template "/etc/init.d/remote_syslog" do
    source "papertrail/remote_syslog_init.erb"
    action :create
    mode "755"
    cookbook 'library'
  end

  service "remote_syslog" do
    action :enable
    supports :status => true, :start => true, :stop => true, :restart => true
    subscribes :restart, "service[#{app_name}]", :delayed
  end

  template "/etc/log_files.yml" do
    source "papertrail/log_files.yml.erb"
    variables(log_file: log_file)
    action :create
    cookbook 'library'
    notifies :restart,"service[remote_syslog]", :delayed 
  end

  monit "remote_syslog"

end
