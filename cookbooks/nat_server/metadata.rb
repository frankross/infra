name             'nat_server'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures nat_server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.13'

depends "iptables"
depends "vpn"
