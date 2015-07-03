default['apps']['user']                       = 'deploy'
default['apps']['group']                      = 'deploy'
default['apps']['location']                   = "/srv/www/ecom-platform"
default['apps']['db_server']                  = "postgresql"
default['ecom-platform']['vcs_address']       = "ecom-platform:frankross/ecom-platform.git"
default['ecom-platform']['vcs_branch']        = "master"
override['nginx']['user']                     = 'deploy'
default["apps"]["init_script_name"]           = "puma"
force_override['nginx']['proxy_send_timeout'] = 600
force_override['nginx']['proxy_read_timeout'] = 600
default["assets"]["s3_bucket"]                = "s3://ecom-platform-assets"
