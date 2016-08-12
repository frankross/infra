default['apps']['user']                       = 'web'
default['apps']['group']                      = 'web'
default['apps']['location']                   = "/srv/www/ecom-web"
default['ecom-web']['vcs_address']       = "ecom-web:frankross/ecom-web.git"
default['ecom-web']['vcs_branch']        = "uat"
override['nginx']['user']                     = 'deploy'
