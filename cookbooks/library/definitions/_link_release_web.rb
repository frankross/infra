define :link_release_web do
  app_user     = node.apps[:user]
  app_group    = node.apps[:group]
  app_location = params[:app_location]
  release_dir  = node.apps.release_dir
#  app_service  = params[:app_service]
  latest_sha   = node.apps.latest_sha
  current_sha  = node.apps.current_sha

  link "#{app_location}/current" do
    to release_dir
    user app_user
    group app_group
    not_if { latest_sha == current_sha}
#    notifies :restart, "service[#{app_service}]", :delayed
  end
end
