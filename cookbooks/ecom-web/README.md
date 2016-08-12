This recipe install and sets up ecom-web application.

Explanation of recipes

This recipe prefix is _ because this recipe wont be used independently
and only will be included in other recipes.

i)_install_awscli
This is a definition in library cookbook which install and configure
awscli with creds.
For more information check library cookbook readme

ii)setup_web_app
This is a definition in library cookbook which is used to clone code
from github, run bundle install and installs ruby on instance


