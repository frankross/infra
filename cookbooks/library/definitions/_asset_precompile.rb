define :_asset_precompile do

  app_user              = node.apps[:user]
  app_group             = node.apps[:group]
  app_location          = params[:app_location]
  environment_variables = params[:environment_variables]
  release_dir           = node.apps.release_dir

  directory "#{app_location}/shared/assets" do
    action :create
    owner app_user
    group app_group
  end

  link "#{release_dir}/public/assets" do
    to "#{app_location}/shared/assets"
  end

  rails_env = node.chef_environment
  Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

  env = Hash[environment_variables.merge("RAILS_ENV" => "production").map{|key, value| [ key.to_s, value.to_s ]}]

  execute "rake assets:precompile" do
    cwd release_dir
    command "PATH=#{node.ruby.bin_location}:$PATH bundle exec rake assets:precompile"
    environment "RAILS_ENV" => "production"
    user app_user
    environment env
  end
end
