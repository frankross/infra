name             'teamcity-ci'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures teamcity-ci'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

depends 'teamcity'
depends 'library'
depends 'java'
depends 'rbenv'
depends 'datadog'
