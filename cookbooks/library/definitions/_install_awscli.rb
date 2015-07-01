define :_install_awscli do

  home=params[:home] || "/root"
  user=params[:user] || "root"

  ["python","python-pip","jq"].each do |pkg|
    package pkg do
      action :install
      not_if "rpm -aq| grep #{pkg}"
    end.run_action(:install)
  end

  execute "install awscli" do
    if node.platform_family =="rhel"
      command "python-pip install awscli"
    elsif node.platform_family=="debian"
      command "pip install awscli"
    end
  end.run_action(:run)

  directory "#{home}/.aws" do
    action :create
    user user
  end.run_action(:create)

  aws_creds = data_bag_item("aws", "awscli")

  template "#{home}/.aws/config" do
    source "awscli/aws_config.erb"
    action :create
    variables(
      region: aws_creds['region'],
      access_key: aws_creds['access_key'],
      secret_key: aws_creds['secret_key']
    )
    cookbook 'library'
    user user
  end.run_action(:create)
end
