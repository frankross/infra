There is a script in ./scripts/launch_server.sh location
This can be used to launch new app server for ecom-platform app and
delayed jobs

Sample Usage: 
sh ./scripts/launch_server.sh ecom-platform-dj-staging-1 staging t2.small ecom-platform delayed_job subnet-d3df5db6 ap-southeast-1a
sh ./scripts/launch_server.sh ecom-docs-staging-1 staging t2.small ecom-docs app subnet-ffe03b88 ap-southeast-1

Go through the script to check more.
You can change the ebs volume space and type parameter in the script.

