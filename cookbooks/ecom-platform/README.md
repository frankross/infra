This recipe install and sets up ecom-platform application.

Explanation of recipes
1)_common.rb

This recipe prefix is _ because this recipe wont be used independently
and only will be included in other recipes.
This recipe sets up a basic source code with database.yml which will be used both by app and delayed jobs.

i)_install_awscli
This is a definition in library cookbook which install and configure
awscli with creds.
For more information check library cookbook readme

ii)setup_app
This is a definition in library cookbook which is used to clone code
from github, run bundle install and installs ruby on instance

iii)_configure_postgres_client 
This run asset precompile on the instances


2)app.rb

This recipe include _common.rb

i)_asset_precompile 
This run asset precompile on the instances

ii)_app_servers
This is used to set up 

i)Puma and configuration
ii)Install nginx and configuration

3) delayed_jobs

This recipe include _common.rb
Then it sets up delayed jobs , creates an init.d script and runs all the jobs on one server


4) delayed_job_1
This recipe include _common.rb
Then it sets up delayed jobs , creates an init.d script and runs only algolia, notifications and sms jobs on the server


4) delayed_job_2
This recipe include _common.rb
Then it sets up delayed jobs , creates an init.d script and runs only upload, download and default jobs on the server

5) cron_jobs
This is to create cron tabs for sync delivery slots and sync
distribution center
