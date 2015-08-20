define :_app_servers do
  app           = params[:name]
  app_user      = node.apps[:user]
  app_group     = node.apps[:group]
  app_location  = params[:app_location]
  app_service   = params[:app_service]

  include_recipe "nginx"

  begin
    r = resources(:package => "nginx")
    r.version node["nginx"]["version"]
    r.notifies :reload, 'ohai[reload_nginx]', :immediately
    r.not_if 'which nginx'
  end

  directory "/var/lib/nginx" do
   user app_user
   group "www-data"
  end

  node.default['datadog']['nginx']['instances']=[{:nginx_status_url => "http://#{node['ipaddress']}/nginx_status/",
                                                  :tags => ["#{node['ipaddress']}"]
  }]
  node.override["datadog"]["tags"].push("nginx")
  include_recipe "datadog::nginx"

  # nginx.conf.erb should be in cookbook which is calling this definition
  template "/etc/nginx/conf.d/#{app}.conf" do
    source "app_servers/nginx.conf.erb"
    variables(app_name: app,
              cname: node[app]["cname"],
              vpc_cidr: node["vpc"]["cidr"])
    owner app_user
    group app_group
    mode "400"
    cookbook "library"
    notifies :reload, "service[nginx]"
  end

  node.override["datadog"]["tags"].push("puma")

  template "#{app_location}/shared/config/puma.rb" do
    source "app_servers/puma.rb.erb"
    owner app_user
    group app_group
    variables(app_location: app_location)
    cookbook "library"
    notifies :restart, "service[#{app_service}]"
  end

  link "#{app_location}/current/config/puma.rb" do
    to "#{app_location}/shared/config/puma.rb"
    user app_user
    group app_group
  end

  template "/etc/init.d/#{app_service}" do
    source "apps/service.erb"
    owner app_user
    group app_group
    mode "00775"
    variables(app: app,
              user: app_user,
              group: app_group,
              env: node.chef_environment,
              project_path: app_location,
              ruby_bin: node.ruby.bin_location,
             )
    notifies :restart, "service[#{app_service}]", :delayed
    cookbook "library"
  end

  service app_service do
    supports status: true, start: true, stop: true, restart: true
    action :enable
  end

  papertrail "app" do
    log_file ["#{app_location}/shared/log/puma.log","/var/log/nginx/*.log"]
  end

  _logrotate "app_logs" do
    path "#{app_location}/shared/log/*.log"
  end

  monit "puma"
  monit "nginx"
end
