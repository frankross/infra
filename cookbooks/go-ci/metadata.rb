name             'go-ci'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures go-ci'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.6'

depends "go"
depends "rbenv"
depends "postgresql"
depends "library"
depends "htpasswd"
