To add a user and give him/her ssh access create a json file in users
databags
./data_bags/users/
Here is a sample file

{
  "id"        : "vipul",
  "comment"   : "vipul",
  "home"      : "/home/vipul",
  "groups"    : ["sysadmin"],
  "passwd"    : "vipulci123",
  "shell"     : "\/bin\/bash",
  "ssh_keys"  : [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfBYVYgmuSt+vs34pHEiQyvcWKyPqqEeKNNsf2fuilYo9GQVVTD7UFLvpv4O6Qd15hF5fEyiV0j0YqFdB0DLN+KCLcfelvGQxnz1/paZigh/deCZdfKDZqe8WhxSoUw8zoJgdmqKK8V6U4uad/6l9IYxcXQjph9d8VBl/YqCKrpV06vHqLnGzSYyVwR9edqdXUNwPcCjFTLjaDGWNMaJa7lGQnADKVL8wvt90yhKcLn/p2e5yzcSTXQ3eo7AX5HyMaw1cLJWZxS4dZyEvYggqIucg2cPK5+jleEO291qBEA7D7RXfISG8WmChb9ERi122cpvLdxGUTn2W0ZByiHS49 vipulsharma2190@gmail.com"
  ]
}

Replace the name with user name
Replace the ssh keys with user's public key and the user will use the
private key to ssh on machines

There are 4 groups
1) internal 
access to teamcity
2) staging 
access to all staging instances
3)production 
access to all production instances
4)sysadmin
access to all instances

Please give access as needed
