define :process_check do

template "/etc/dd-agent/conf.d/process.yaml" do
    source "process/process.yaml.erb"
    owner "dd-agent"
    mode 0755
    cookbook 'library'
    variables(process_checks: node["monitoring"]["processes"] )
    action :create
    notifies :restart , "service[datadog-agent]", :delayed
  end


  template "/etc/dd-agent/conf.d/process.py" do
    source "process/process.py.erb"
    owner "dd-agent"
    mode 0755
    cookbook 'library'
    action :create
    notifies :restart , "service[datadog-agent]", :delayed
  end

end
