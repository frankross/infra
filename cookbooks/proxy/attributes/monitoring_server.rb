default['datadog']['http_check']['notify_members'] = ['vipul@codeignition.co']

instances_urls=node.proxy.frontend_servers


default['datadog']['http_check']['instances'] =[]
instances_urls.each do |instance|
  default['datadog']['http_check']['instances'].push ({

    'name' => "#{instance["name"]}",
    'url' =>  "https://#{instance["cname"]}",
    'timeout' => "2",
    'threshold' => "2",
    'window' => "6",
    'notify_members' => node['datadog']['http_check']['notify_members']
  }
                                                      )
end
