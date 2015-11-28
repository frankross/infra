name             'proxy'
maintainer       'support'
maintainer_email 'support@codeignition.co'
license          'All rights reserved'
description      'Installs/Configures proxy'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.13'

depends 'library'
depends 'iptables'
depends 'datadog'
