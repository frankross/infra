# HAProxy

## _haproxy recipe

* Haproxy user creation
* Haproxy installed
* Add ssl certificates for frankross.in.
	
	These certificates are encypted and and decrypted during chef-client run and then ssl certs are added to haproxy configuration.

* Haproxy configuration
  
  we use chef to identigy which servers are running ecom-platform recipe and which servers are runnign ecom-docs and then use this to configure the haproxy.

  Haproxy uses this script to search for the servers. We have a conventions to name app server recipe as app.rb. We use this
  over here in this search script to identify app server and add them to haproxy.

	servers =  search(:node,"run_list:recipe\\[#{server[:name]}\\:\\:app\\] AND chef_environment:#{node.chef_environment}")

* Haproxy restart if configuration changes.
* Monitor haproxy
  
  We use datadog for monitoring. There is a datadog integration for haproxy which gives us a lot of metrics about request and bounce rates. In this we configure the datadog to send haproxy metrics to our datadog account.

* Allow 80 and 443 port on haproxy servers.
* Logrotate the haproxy logs
* setup papertrail to send haproxy logs to our papertrail accoumt


## Keepalived

Keepalived is used to monitor haproxy on master and slave to switch elastic ip if master crashes. Keepalived run on both master and slave haproxy. It monitors haproxy process. If haproxy dies on master the keepalived master goes into fault state. It communicates with slave keepalived about this.

Slave keepalived when sees that master is in fault, promotes itself to master and toggles the elastic ip to itself. Thus the failover is completed.

Now if origninal master comes back, it starts acting as keepalived slave and thus carrying on failover.

## Secondary IP

The secondary ip is assigned to both master and slave so that elastic ip can be attached to this secondary ip.

	www.frankross.in => <prod-elastic-ip>
  	staging.frankross.in => <staging-elastic-ip>

If master crashed keepalived switches this elastic ip to the slave and thus our traffic will not go to slave instead of master and our site wont go down.

## Monitoring server

We monitor our urls with monitoring server recipe. If the urls go down it will send an email to the team as well as slack.

## Master recipe
This recipe uses _haproxy recipe and then configures the keepalived to point to the slave and communicate with him for failover.

## Slave recipe

This recipe uses _haproxy recipe and then configures the keepalived to point to the master and communicate with him for failover.
