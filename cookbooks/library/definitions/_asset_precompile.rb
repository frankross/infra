define :_asset_precompile do

  app           = params[:name]
  app_user      = node.apps[:user]
  app_group     = node.apps[:group]
  app_location  = params[:app_location]

  directory "#{app_location}/shared/assets" do
    action :create
    owner app_user
    group app_group
  end

  link "#{app_location}/current/public/assets" do
    to "#{app_location}/shared/assets"
  end

  rails_env = node.chef_environment
  Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

  execute "rake assets:precompile" do
    cwd "#{app_location}/current"
    command "PATH=#{node.ruby.bin_location}:$PATH bundle exec rake assets:precompile"
    environment "RAILS_ENV" => rails_env
    user app_user
  end
end
