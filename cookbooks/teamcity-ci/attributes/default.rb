default["teamcity_server"]["version"] = "9.0.5"
override['java']['jdk_version']       = '7'
default["ci"]["ruby_version"]         = ["2.1.5","2.2.2"]
default["ci"]["ruby_gems"]            = ["bundle"]
override['java']['jdk_version']       = '7'
if node.platform_family == "rhel"
  override['postgresql']['client']['packages']  = %w{postgresql-devel}
  override['postgresql']['server']['packages']  = %w{postgresql-server}
  override['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
elsif node.platform_family == "debian"
  override['postgresql']['version']             = "9.3"
  override['postgresql']['server']['packages']  = ["postgresql-9.3"]
  override['postgresql']['client']['packages']  = ["postgresql-client-9.3","libpq-dev"]
  override['postgresql']['contrib']['packages'] = ["postgresql-contrib-9.3"]
  override['postgresql']['pg_hba']              = [
    {:type => 'host', :db => 'all', :user => 'all', :addr => '0.0.0.0/0',:method => 'trust'},
    {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'trust'},
    {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'trust'},
    {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
    {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
  ]
end
default["teamcity"]["home"]= node["teamcity_server"]["root_dir"]
default["teamcity"]["cname"] = "teamcity.frankross.in"
