# emami-DEVOPS

This repository contains configuration management files for emami environment at AWS.

## Environment Details
emami environment is behind a VPC rails application using RDS postgres instance, apart from this it has following services:

* OpenVPN Server with easy rsa configuration
* Chef server
* HAProxy
* CI
* Packaging and deployment using CI triggers
* other helper stuff

**Note:** All these boxes follow a convention to tag them at AWS console, so you if you look at running instances, you will understand which box does what, the convention also includes subnet, availabilty zone, environment and purpose for the box.


## VPC

We have two types of subnets in VPC, all public facing servers are in subnet 1 and all private servers are in subnet 1, no one can reach servers in subnet 1 unless they have vpn clients


## VPN

The whole environment is accessible on with vpn client, which uses easy rsa as a pki provider. to generate a vpn key:

```
cd /etc/openvpn/easy-rsa
source ./vars
rake <client name>
```

EasyRSA is bundled with OpenVPN, look at OpenVPN cookbook for more details, we have decided on a strange internal IP address range so it does not create conflict with existig 192.168.x.x and 172.16.x.x networks which are commonly found at your home and offices, so that VPN can run smoothly.


## Chef

The entire emami environment is controlled by chef and its central piece around making sure that we have repetable, atomic and transaction less infrastructure with eventual consistenty with help from chef to converge nodes to ultimate configurationg parameters.

Please note, that any changes made to the files manually will be over-written on next deployment run.


```
Chef Server IP Address: 54.254.151.183
```

Chef server validation key: validator.pem with your personal key

we use berkshelf for managing chef dependencies and leveraging community cookbooks, unless required, you should not try to hand roll your own cookbook, try to use a community cookbook and then over-ride is as per requirement

Chef Structure

```
    .
    ├── Berksfile                   <--- THIS IS GEMFILE
    ├── Berksfile.lock
    ├── certificates
    │   └── README.md
    ├── chefignore
    ├── cookbooks                   <--- THIS IS WHERE YOUR COOKBOOKS RESIDE
    │   ├── base
    │   ├── teamcity-ci
    │   ├── ecom-docs
    │   ├── vpn
    │   ├── proxy
    │   ├── ecom-platform
    │   ├── library                 <--- INFRASTUCTURE MANIFEST LIBRARY
    │   ├── nat_server
    ├── data_bags                   <--- THIS IS YOUR META-INFORMATION
    │   ├── aws                     <--- AWS users keys
    │   ├── databases               <--- encrypted databags containing database information
    │   ├── ecom-docs               <--- ecnrypted databags containing app secrets for ecom-docs
    │   ├── ecom-platform           <--- ecnrypted databags containing app secrets for ecom-platform
    │   ├── haproxy                 <--- databags for haproxy creds and ssl keys
    │   ├── users                   <--- databags for creating user profiles on instances
    ├── environments
    │   ├── staging                 <--- staging environment variables
    │   ├── internal                <--- intenral env for ci and other internal services
    │   ├── production              <--- production environment
    │   └── README.md
    ├── Gemfile
    ├── Gemfile.lock
    ├── README.md
```

### How do we configure a box?

* We choose a node and apply appropriate cookbooks on that node.

### How do I launch a new box?
* No, you don't, unless you need a new service.
* If you are adding a new service
	* Goto EC2 console
	* Choose subnets - public or private
	* Launch the box
	* Install chef client using knife bootstrap
	
		`knife bootstrap <node-ip> -x ubuntu --node-name <node-name> -E <node-env> -i <node-key> --sudo`
	
	* start adding new cook books

### How do I run chef-client on app servers ?
* To run chef-client on servers 2 steps can be followed
* Run using knife
  * Logic is to search for all node with a particular recipe, and run command on them
  * knife ssh "chef_environment:production AND recipe:APP_NAME\:\:app"
    "sudo chef-client" -x 'ubuntu' -a ipaddress -i ~/.ssh/key --no-host-key-verify" 
  * example, knife ssh 'chef_environment:production AND recipe:ecom-platform\:\:app' 'sudo chef-client' -x 'ubuntu' -a ipaddress -i ~/.ssh/emami-aws-master-key.pem --no-host-key-verify

* Run using CI build
  * Production/Staging deploy tasks, actually change the sha version which is to be deployed of app
    and runs chef-client on app.
  * So if we run production deploy it will deploy the latest sha from
    which ever branch is specified in attributes(In our case it is master)
  * It very important to be careful with this approach, can cause
    unwanted issues.

### How do you control params, environment variables?

The environment variables for apps

0. Not encrypted  <--- ./environments/* folder
0. Encrypted      <--- ./data_bags/<app>/* folder

db creds are in <--- ./data_bags/databases/* folder


### How do I update data bags ?

To update any variable for application, you need to update the databag:

##### Unencrypted data bags

To change these go to databags, open the file make the changes and push
the changes to github. We have a build on teamcity which upload the
databags if someone commits. Alternatively use
knife data bag from file <databag> <file.json>

##### Encrypted data bags

To change these download the secret file from 

	s3://emami-ci-packages/deploy_keys/databag_secret

now to edit use this command. For example to edit ecom-platform databags

	knife data bag edit ecom-platform settings --secret-file ./.chef/databag_secret

Save the changes. Now replace the existing `./data_bags/ecom-platfomr/settings.json` with the output of this command
	
	knife data bag show ecom-platform settings -F json
	
and push to github otherwise your changes will be removed.


### How do I start reading about cookbooks

We have a cookbook called library cookbook which has definitions in it. We use these common defitions to setup app server. You will find different definition which has different purposes. They take attributes and variables as inputs and then do things acordindly.

You can start with ecom-docs app, see what resources(defnitions) is being used there and then subsequently read readme for library cookbook where the detailed description for that definition is given.

Then you can start reading the ecom-platform cookbook.

### How do i read a specific cookbook with parameters

A cookbook has 

1. attributes
2. recipes
3. files
4. templates
5. metadata.rb

When you start reading a cookbook it will contain attributes , templates
and resource from other cookbooks.The files are in directories with same
name in a specific cookbook.

Please read DeploymentReadme.md next
