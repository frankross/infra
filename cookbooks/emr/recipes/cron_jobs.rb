app                              = "emr"
app_location                     = node.apps.location

cron "reset_prescriptions" do
  minute "10"
  hour "*"
  user "deploy"
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake reset_prescriptions >> #{app_location}/current/log/cron.log 2>&1'"
end

cron "dispatch_callbacks" do
  minute "0"
  hour "*"
  user "deploy"
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake dispatch_callbacks >> #{app_location}/current/log/cron.log 2>&1'"
end

cron "product_variant_sync" do
  minute "*"
  hour "6"
  user "deploy"
  command "/bin/bash -l -c 'cd #{app_location}/current;source /etc/default/#{app}.conf;RAILS_ENV=production bundle exec rake product_variant_sync >> #{app_location}/current/log/cron.log 2>&1'"
end