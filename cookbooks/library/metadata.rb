name             "library"
maintainer       "vipul"
maintainer_email "vipul@codeignition.co"
license          "All rights reserved"
description      "Installs/Configures library"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.6"

depends 'nginx'
depends 'postgresql'
depends 'datadog'
depends 'logrotate'
