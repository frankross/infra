name             'base'
maintainer       'emami'
maintainer_email 'vipul@codeignition.co'
license          'All rights reserved'
description      'Installs/Configures base'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'users'
depends 'sudo'
depends 'datadog'
depends 'ntp'
depends 'newrelic'
