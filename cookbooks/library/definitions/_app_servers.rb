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

  # nginx.conf.erb should be in cookbook which is calling this definition
  template "/etc/nginx/conf.d/#{app}.conf" do
    source "nginx/nginx.conf.erb"
    variables(app_name: app)
    owner app_user
    group app_group
    mode "400"
    notifies :reload, "service[nginx]"
  end

  template "#{app_location}/current/config/puma.rb" do
    source "app_servers/puma.rb.erb"
    owner app_user
    group app_group
    variables(app_location: app_location)
    cookbook "library-opsworks"
    notifies :restart, "service[#{app_service}]"
  end

  instance_id   = `curl -s http://169.254.169.254/latest/meta-data/instance-id`
  load_balancer = node[app][:load_balancer]

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
              instance_id: instance_id,
              load_balancer: load_balancer
             )
    notifies :restart, "service[#{app_service}]", :delayed
    cookbook "library-opsworks"
  end

  service app_service do
    supports status: true, start: true, stop: true, restart: true
    action :enable
  end

end
