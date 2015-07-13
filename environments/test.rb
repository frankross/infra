name 'internal'
description 'internal environment file'

override_attributes(
  :vpc => {
    :cidr => "10.60.0.0",
    :netmask => "255.255.0.0",
    :nat_netmask => "16"
  }
)
