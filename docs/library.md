# Requirements
This is library cookbook, has functions and infrastructure support This is required for most of the functions required to get infrastructure going
This cookbook has no recipes. 
It has definitions which are required by multiple cookbook.
I will explain the definitions now.

1)setup_app.rb
This definition is used to setup the app server.It creates the deploy
user which is used to run the app, sets up github , clones the source
code and then runs bundle install

The source code is in /srv/www/<app> directory.
There are 3 directories in this

**releses
This directory has last 5 releases of the source code in it.The current
release is symlinked to create the current directory

**current
The current directory is a sym link of latest release of the source
code.The configuration which is maintained by chef for eg. database.yml
and other configs are maintained in the shared directory and symlinked
in this directory.

**shared
It has multiple direcories such as gems,
config,pids,logs,sockets(puma),tmp
All the files in this directory are configured by chef and symlinks are
created in current directory

2)_git_setup.rb
This definition is used to set up ssh folder of deploy user alongwith
private key and config file so that source code can be cloned from
private repo

3)_asset_precompile
This definition takes some parameters and runs asset precompile on
the source code in current folder.

4)_configure_postgres_client.rb
This definition is used to configure database.yml file for the rails
app.It downloads the secret key from s3 , decrypts the database databag
and uses this to configure the yml file.
It also run db:migrate rake task.

5)_app_server.rb
This is used to configure nginx and puma which are used to run the app.
Nginx connects to puma socket and listes on port 80. Config is in
/etc/nginx/conf.d/<app>.conf. Nginx also redirects specific urls only
which are specified in this file which in turn are specified in
environment file for eg environments/staging.rb

6)_install_awscli.rb
This definition is used to install awscli on an instance which is used
to download private and secret keys.

7)papertrail.rb
This definition is used to configure papertrail on the app server. It
takes the log files as parameter and then configures papertrail to send
this log files to papertrail server for log tailing

8)process_check.rb
This is used to a process check in datadog.It monitors if the process is
running and notifies the datadogs if the process is down. It takes process name as paramter

9)knife_setup
This is used to setup chef and a knife user on an instance





