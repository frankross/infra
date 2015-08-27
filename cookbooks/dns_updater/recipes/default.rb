#
# Cookbook Name:: dns_updater
# Recipe:: DNSUpdator Default
#
# Copyright 2014, CodeIgnition
#
# All rights reserved - Do Not Redistribute
# This cookbook updates route53 with all chef nodes and create A and PTR records


['libxml2-dev','libxslt1-dev','libpcre3-dev',"libqt4-dev","zlib1g-dev","build-essential","libpq-dev","libpq5","nodejs"].each do |pkg|
  package pkg do
    action :nothing
  end.run_action(:install)
end


chef_gem 'aws-sdk-v1'
require 'aws-sdk-v1'

awscli_aws_creds = data_bag_item("aws", "awscli")
aws_access_key   = awscli_aws_creds["access_key"]
aws_secret_key   = awscli_aws_creds["secret_key"]
aws_region       = awscli_aws_creds["region"]

AWS.config(:access_key_id => aws_access_key, :secret_access_key => aws_secret_key, :region => aws_region)
ec2        = AWS::EC2.new
dns_records= AWS::Route53.new.client.list_resource_record_sets(options = {:hosted_zone_id=>node["aws"]["route53"]["zone_id"]})[:resource_record_sets]
a_records   = dns_records.select { |x|  x[:type] == "A"}

ec2.instances.each do |instance|
  if instance.status.to_s.downcase == "running" and instance.tags["Name"] != nil
    instance_name            =          instance.tags["Name"].to_s.split(" - ")[-1].downcase
    instance_ip              =          instance.private_ip_address.to_s
    a_record_name            =          "#{instance_name}.#{node['aws']['route53']['zone']}"
    instance_dns_record      =          dns_records.select {|k| k[:name]=="#{a_record_name}."}
    a_records.delete(instance_dns_record[0])

    unless instance_name.nil?
      if instance_dns_record == [] or instance_dns_record[0][:resource_records][0][:value] != instance_ip
        update_records "A" do
          record_name a_record_name
          type "A"
          record_action "UPSERT"
          ttl 360
          value instance_ip
          access_key_id aws_access_key
          secret_access_key aws_secret_key
          region aws_region
        end
      end
    end
  end
end

a_records.each do |record|
  rrsets = AWS::Route53::HostedZone.new(node["aws"]["route53"]["zone_id"]).rrsets
  rrset = rrsets[record[:name], 'A']
  rrset.delete
end

cname_servers = {}
node["servers"]["cname"].each do |cname,recipe|
  nodes = search(:node, "run_list:recipe\\[#{recipe}\\]")
  count = 1
  nodes.each do |node|
    cname_servers["#{cname}0#{count}"] = node.name
    count += 1
  end
end

cname_servers.each do |cname_record,a_record|
  update_records "CNAME" do
    record_name "#{cname_record}.#{node['aws']['route53']['zone']}"
    type "CNAME"
    record_action "UPSERT"
    ttl 360
    value "#{a_record}.#{node['aws']['route53']['zone']}".downcase
    access_key_id aws_access_key
    secret_access_key aws_secret_key
    region aws_region
  end
end

cron "chef-client" do
  minute "*/3"
  hour "*"
  command "chef-client"
end
