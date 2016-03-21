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

cron "update categories active variants" do
  minute "0"
  hour "23"
  user 'deploy'
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake scheduled:active_variants_in_category >> #{app_location}/current/log/cron.log 2>&1'"
end

cron "sync emr digitization request processing availability" do
  minute "30"
  hour "*"
  user 'deploy'
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake emr:sync_digitization_processing_available_at >> #{app_location}/current/log/cron.log 2>&1'"
end

cron "Run algolia health check program every 30 mins to verify the settings on the algolia server" do
  minute "30"
  hour "*"
  user 'deploy'
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake algolia:index_check >> #{app_location}/current/log/cron.log 2>&1'"
end
