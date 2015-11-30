default["aws"]["route53"]["zone_id"] = "Z201X32LCN5D4R"
default["aws"]["route53"]["zone"]    = "emami.vpc"
default[:set_fqdn] = '*.emami.vpc'
default[:servers][:cname]={
  "teamcity"=> 'teamcity-ci\:\:server',
  "vpn"   => 'vpn\:\:default',
}
