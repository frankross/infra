define :_configure_postgres_client   do

  app                   = params[:name]
  app_user              = node.apps[:user]
  app_group             = node.apps[:group]
  app_location          = params[:app_location]
  app_service           = params[:app_service]
  environment_variables = params[:environment_variables]

  include_recipe "postgresql::client"

  chef_config_path = Chef::Config['file_cache_path']

  secret_file_name =  node["databag"]["secret_location"].split("/")[-1]
  execute "download secret key" do
    command "su - root -c 'aws s3 cp #{node["databag"]["secret_location"]} #{chef_config_path}'"
    not_if { ::File.exists?("#{chef_config_path}/#{secret_file_name}") }
  end.run_action(:run)

  secret = `cat #{chef_config_path}/#{secret_file_name}`
  db_creds = Chef::EncryptedDataBagItem.load("databases",app,secret).to_hash[node.chef_environment]

  db_file_location =  "#{app_location}/shared/config/database.yml"

  template  db_file_location do
    source "apps/database.yml.erb"
    owner node.apps[:user]
    group node.apps[:group]
    mode "400"
    variables(database: db_creds["database"],
              pool: db_creds["pool"],
              username: db_creds["username"],
              password: db_creds["password"],
              host: db_creds["host"],
              adapter: db_creds["adapter"],
              encoding: db_creds["encoding"],
              port: db_creds["port"]

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

  env = Hash[environment_variables.merge("RAILS_ENV" => "production").map{|key, value| [ key.to_s, value.to_s ]}]
  temp_dir = Chef::Config['file_cache_path']
  dbmigrate   = YAML.load(File.read "#{temp_dir}/sha_number.yml")[node.chef_environment][app]["dbmigrate"]
  execute "db_migrate_#{params[:app_name]}" do
    cwd "#{app_location}/current"
    command "PATH=#{node.ruby.bin_location}:$PATH bundle exec rake db:migrate"
    environment "RAILS_ENV" => "production"
    user app_user
    environment env
    only_if {dbmigrate == true}
  end
end
