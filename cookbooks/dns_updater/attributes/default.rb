default["aws"]["route53"]["zone_id"] = "Z29TZFA90X8XV6"
default["aws"]["route53"]["zone"]    = "emami.vpc"
default[:set_fqdn] = '*.emami.vpc'
default[:servers][:cname]={
  "teamcity"=> 'teamcity-ci\:\:server',
  "vpn"   => 'vpn\:\:default',
}
