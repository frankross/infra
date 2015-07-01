define :_configure_postgres_client   do

  app           = params[:name]
  app_user      = node.apps[:user]
  app_group     = node.apps[:group]
  app_location  = params[:app_location]
  app_service   = params[:app_service]

  include_recipe "postgresql::client"

  aws_creds = data_bag_item("databases", app)[node.chef_environment]

  db_file_location =  "#{app_location}/shared/config/database.yml"

  template  db_file_location do
    source "apps/database.yml.erb"
    owner node.apps[:user]
    group node.apps[:group]
    mode "400"
    variables(database: aws_creds["database"],
              pool: aws_creds["pool"],
              username: aws_creds["username"],
              password: aws_creds["password"],
              host: aws_creds["host"],
              adapter: aws_creds["adapter"],
              encoding: aws_creds["encoding"],
              port: aws_creds["port"]

             )
    cookbook 'library'
    action :create
    notifies :restart, "service[#{app_service}]", :delayed
  end

  link "#{app_location}/current/config/database.yml" do
    to "#{app_location}/shared/config/database.yml"
    user app_user
    group app_group
  end
end
