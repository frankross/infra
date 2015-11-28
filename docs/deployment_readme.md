We use continues deployment strategy in which whenever there is a commit on master branch , CI server automatically run the specs and start staging deploy.

### Staging Deploy in CI server

We maintain a file named `sha_number.yml` in which we specify the sha number of code which will be deployed on the servers.
Production and staging have separate entries. When we trigger staging deployment it picks up the latest commit from
branch specified and writes that to sha_number.yml file. Then it uploads it to s3 bucket emami-ci-packages-2.

#### Chef-client run for app servers

0. User creation

	we use deploy user to run all the process and all the source code is owned by deploy user. We create deploy user and group in first steps of deployment.

0. Git setup

	The git is setup for the deploy user. The ssh key is written to .ssh folder in deploy user home and config file is created so that it can clone the code from github.

	The directory structure is created as specified in readme for library cookbook.

	Source code is cloned in /srv/www/<app>/releases directory.
We keep last 5 release so that in case of emergency we can quickly move
to last stable branch.
The current branch is symlinked to the release which you want in
production.

0. Git clone

	If the sha specified in sha_number.yml is same as current sha of source code , new code is not cloned. If it is different, the code is cloned and symlinked to current branch.

	Bundle and ruby are installed in next steps.

0. Asset precompile is run and stored in `/srv/www/<app>/shared/assets` directory. It is then symlinked in current source code.

0. We use puma and nginx to app server . These are configured in _app_servers definition. If new source code is cloned, puma, nginx and other scripts are restarted.

0. Process checks are added after that for datadog


#### Deploying a particular commit or branch


Chef checks the below mentioned variable for the branch it wants to deploy. For example:

	default['ecom-platform']['vcs_branch']        = "master"

If you want to deploy other branch change this attribute and then follow the docs `ChangeCookbook.md`. Deployments will always clone the head of the branch which you specified. So in order to deploy a particular commit move your head to that commit
and push to github.

### Chef-client run for haproxy servers

0. Haproxy user creation
1. Haproxy installed
2. Haproxy configuration

	We use chef to identify which servers are running ecom-platform recipe and which servers are runnign ecom-docs and then use this to configure the haproxy.

	Haproxy uses this script to search for the servers. We have a conventions to name app server recipe as `app.rb`. We use this over here in this search script to identify app server and add them to haproxy.

	servers = search(:node,"run_list:recipe\\[#{server[:name]}\\:\\:app\\] AND chef_environment:#{node.chef_environment}")

3. Haproxy restart if configuration changes.
4. Keepalived is used to monitor haproxy on master and slave to switch elastic ip if master crashes


Please read `ecom-docs` readme or `ecom-platform` readme next.
