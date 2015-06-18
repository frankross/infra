name 'internal'
description 'internal environment file'

override_attributes(
  :vpc => {
    :cidr => "10.60.0.0/16"
  }
)
