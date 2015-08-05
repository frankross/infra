app                              = "ecom-platform"
app_location                     = node.apps.location

cron "sync delivery slots" do
  minute "0"
  hour "*"
  user "deploy"
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake asset_tracker:sync_delivery_slots  >> #{app_location}/current/log/cron.log 2>&1'"
end

cron "sync distribution center" do
  minute "0"
  hour "*"
  user "deploy"
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake asset_tracker:sync_distribution_centers >> #{app_location}/current/log/cron.log 2>&1'"
end
