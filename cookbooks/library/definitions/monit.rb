define :monit do

  app = params[:name]
  package "monit"

  cookbook_file "/etc/monit/conf.d/#{app}" do
    source "monit/#{app}"
    mode "644"
    cookbook 'library'
    notifies :restart,"service[monit]", :delayed
  end

  service "monit" do
    action :enable
    supports :status => true, :start => true, :stop => true, :restart => true
  end
end
