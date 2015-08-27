All the cookbooks have a file metadata.rb
for example for ecom-platform cookbook.

name             'ecom-platform'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures ecom-platform'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.21'

depends "library"
depends "base"

The version of the cookbook is incremented with every change.
The version of cookbook are locked for staging and production so that
stable cookbook run on both environments.


Suppose you have changed anything on ecom-platform cookbook and want to deploy it on
staging
Please update the metadata.rb , Change the locked version in the 
./environments/staging.rb to new version and then push all the code
The infra build in teamcity will upload cookbook and environments

Alternatively use this

knife cookbook upload ecom-platform
knife environment from file ./environments/staging.rb
to upload both changes
