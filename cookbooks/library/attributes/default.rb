default['apps']['max_number_of_release_dirs'] = 5
default["apps"]["user"]                       = "deploy"
default["apps"]["group"]                      = "deploy"
default["ci"]["bucket"]                       = "s3://emami-ci-packages"
default.ruby[:bin_location]                   = "/usr/bin"
default["chef_server"]["url"]                 = "https://chef-server.emami.vpc/organizations/emami"
default["ruby"]["s3_location"]                = "s3://emami-ci-packages/ruby/ruby-2.2.2-2_amd64.deb"
default["databag"]["secret_location"]         = "s3://emami-ci-packages/deploy_keys/databag_secret"
