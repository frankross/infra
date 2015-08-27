We create a file /etc/default/<app>.conf for each app which has all the
environment variables needed by an app to run.

There are 3 locations of these env variables.

1)Environment Directory and related environment file
For example in ./environments/staging.rb there are 
  "ecom-platform" => {
    "cname" =>'staging.frankross.in',
    "environment_variables" => {
      :AWS_S3_BUCKET_NAME=>"emami-staging",
      :CIRCLE_ARTIFACTS=>true,
      :NEW_RELIC_AGENT_ENABLED => true

These 3 environment variables will be added to file by recipes
The variable which dont need to be kept secret or encrypted are kept
here
To add new variable just add more after this will correct format.


2) Encrypted Databag

The variables which should not be pushed into git and need encryption
are ecnrypted in databag in form of json.
for example for ecom-platform app the variables are in 
./data_bags/ecom-platform/settings.json
There is a key databag_secret in s3 bucket which is used to encrypt or
decrypt these databags
This is a sample command to show the contents of databag
knife data bag show ecom-platform settings  --secret-file ./.chef/databag_secret


Updating the databags
To add new env variables or change existing ones
use this command 
knife data bag edit ecom-platform settings  --secret-file <path to secret file>

After saving run 
knife data bag show ecom-platform settings  -F json
Put this new json in ./data_bags/ecom-platform/settings.json
and push to github


3) Chef nodesearch 
For example memcached servers.
We can hard code the ip of memcached server in either of above but there
is a better way which we do
We use chef to search the node which has memcahced recipe running on it
and then get the ipaddress from this search query.
This allows us to dynamically locate memcached server address.







