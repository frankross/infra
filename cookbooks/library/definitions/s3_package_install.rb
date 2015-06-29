define :s3_package_install do
  _install_awscli

  source         =   params[:source]
  temp_dir       =   Chef::Config['file_cache_path']
  package_name   =   source.split("/")[-1]
  name           =   params[:name]
  version        =   params[:version] || package_name.split('_')[1]

  if node['platform_family']=='rhel'
    check="rpm -qa | grep #{package_name.gsub(/\.rpm/, '').gsub(/\.noarch/, '')}"
    action_to_remove="remove"
  elsif node['platform_family']=='debian'
    check="dpkg -s #{params[:name]} | grep Version | grep #{version}"
    action_to_remove="purge"
  end

  log "downloading #{node.apps[:package]} for #{params[:name]} from #{source}, sit tight"

  bash "downloading #{node.apps[:package]} for #{params[:name]}" do
    user 'root'
    cwd temp_dir
    code "aws s3 cp #{source} ./"
    creates "#{temp_dir}/#{package_name}"
    notifies :"#{action_to_remove}", "package[#{params[:name]}_remove]", :immediately
    notifies :install,"package[#{params[:name]}_install]", :immediately
    not_if check
  end

  package "#{params[:name]}_remove" do
    package_name name
    provider node.apps[:package_manager]
    action :nothing
  end

  package "#{params[:name]}_install" do
    package_name "/#{temp_dir}/#{package_name}"
    provider node.apps[:package_manager]
    action :nothing
    notifies :run,"execute[remove old package]", :immediately
  end

  execute "remove old package" do
    command "rm -f /#{temp_dir}/*.#{node.apps[:package]}"
    action :nothing
  end
end
