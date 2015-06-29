default['apps']['max_number_of_release_dirs'] = 5
default["apps"]["user"]                       = "deploy"
default["apps"]["group"]                      = "deploy"
default["ci"]["bucket"]                       = "s3://emami-ci-packages"
default.ruby[:s3_location]                    = "s3://emami-ci-packages/ruby/ruby_2.2.2-2_amd64.deb"
default.ruby[:bin_location]                    = "/opt/ruby/embedded/bin"
