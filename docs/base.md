base cookbook

This cookbook contains
1) Hostname recipe

This recipe sets up the hostname for a node.The fqdn is <node-name>.emami.vpc
It also adds this to /etc so that changes to hostname are still there
after a reboot

2)users_manage recipe

This recipe is to create ssh profile for users to login on ec2
instances.
The users databag has all the users and all relevant information
required to create a ssh profile for a user alongwith environments.
This recipe create profiles for users who belong to
1) sysadmin group
2) <node.chef_environment> group

3) default recipe
This includes both hostname and users_manage recipe and is run on all
instances
