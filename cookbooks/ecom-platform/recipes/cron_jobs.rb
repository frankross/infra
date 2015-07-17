app                              = "ecom-platform"
app_location                     = node.apps.location

cron "sync delivery slots" do
  hour "*"
  user "deploy"
  command "cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake asset_tracker:sync_delivery_slots"
end

cron "sync distribution center" do
  hour "*"
  user "deploy"
  command "cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake asset_tracker:sync_distribution_centers"
end
