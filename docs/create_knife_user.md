# Knife User

Log in to chef-server 10.70.0.96

Run this command to create a user

	chef-server-ctl user-create USER_NAME FIRST_NAME [MIDDLE_NAME] LAST_NAME EMAIL PASSWORD (options)

This will give a private key. This key will be used to authenticate with the chef-server. Store it as `<USER-NAME>.pem`.

Then run this command to give a user admin access

	chef-server-ctl org-user-add emami USER_NAME --admin

Clone `frankross/infra` repo to your laptop. In infra repo, create a directory `.chef`

In that create a file `knife.rb` with this config

```
log_level                :info
log_location             STDOUT
node_name                'USER_NAME'
client_key               '<path>/infra/.chef/USER_NAME.pem'
validation_client_name   'chef-validator'
validation_key           '<path>infra/.chef/chef-validator.pem'
chef_server_url          'https://chef-server.frankross.in/organizations/emami'
syntax_check_cache_path  '<path>/infra/.chef/syntax_check_cache'
knife[:cookbook_path] = '<path>/infra/cookbooks'
knife[:editor] = 'vim'
```

After this you are setup to use knife.
