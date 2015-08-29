# eCom Platform Deployment

This recipe install and sets up ecom-platform application.

###  1) _common.rb

This recipe prefix is `_` because this recipe wont be used independently and only will be included in other recipes. This recipe sets up a basic source code with `database.yml` which will be used both by app and delayed jobs.

#### _install_awscli

This is a definition in library cookbook which install and configure awscli with creds. For more information check library cookbook readme

#### setup_app

This is a definition in library cookbook which is used to clone code from github, run bundle install and installs ruby on instance.

#### _configure_postgres_client 

This is used to setup database.yml and install postgres packages on app servers.

### 2) app.rb

This recipe include _common.rb

#### _asset_precompile 

This run asset precompile on the instances

#### _app_servers

This is used to set up 

0. Puma and configuration
0. Install nginx and configuration

### 3) delayed_jobs

This recipe include _common.rb. Then it sets up delayed jobs, creates an init.d script and runs delayed jobs.


### 4) cron_jobs

This is to create cron tabs for sync delivery slots and sync distribution center.
