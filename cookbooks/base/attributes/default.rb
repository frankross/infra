default[:datadog][:api_key]          = "9f8eedcd843ebe6780aee73902f2ee71"
default[:datadog][:application_key]  = "cbb3156bbd328cc35496dbc2cc2db202af82f1e7"

default[:newrelic][:server_monitoring][:license] = 'b959fb74d9ac626cea10fb527dbf8b4c68b5e068'

override['datadog']['tags'] = []
case node.platform_family
when "rhel"
    override['datadog']['agent_version'] = "5.3.0-1"
when "debian"
    override['datadog']['agent_version'] = "1:5.3.0-1"
end
override["ntp"]["servers"]=["server 3.in.pool.ntp.org",
                      	   "server 0.asia.pool.ntp.org",
                      	   "server 2.asia.pool.ntp.org"]
