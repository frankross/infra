#!/bin/bash
#script to bring up servers with attached EBS volumes

instance_ami="ami-6a585c38"
instance_name="$1"
instance_env="$2"
instance_type="$3"
application="$4"
role="$5"
subnet="$6"
zone="$7"
storage_size=20
storage_type="standard"
delete_on_termination=true
key="emami-aws-master-key.pem"
security_group="sg-5b5bce3e"

#exit with usage if no arguments are given
if [ $# -lt 1 ]
then
	echo "Usage: $0 instance_name(ecom-platform-staging-XX) instance_env(production/staging) instance_type(m3.medium) application role(app/delayed_job) subnet availabilityzone"
	echo "Sample Usage: sh $0 ecom-platform-staging-1 staging t2.small ecom-platform delayed_job subnet-d3df5db6 ap-southeast-1a"
	exit 1
fi

if [ "$role" == "app" ]; then
runlist="recipe[base::$instance_env],recipe[$application::app]"
elif [ "$role" == "delayed_job" ]; then
runlist="recipe[base::$instance_env],recipe[$application::delayed_job]"
fi

echo "Setting Instance Name: $instance_name"
echo "Setting Instance EBS Size: $storage_size"
echo "Setting Instance Zone : $zone"
echo "Setting Instance Subnet : $subnet"
echo "Setting Instance Type : $instance_type"
echo "Setting Security Group : $security_group"
echo "Setting Instance Subnet : $subnet"
echo "Setting Instance AMI: $instance_ami"
echo "Setting runlist : $runlist"
echo "Setting delete_on_termination : $delete_on_termination"

snapshot_id=$(aws ec2 describe-images --image-ids $instance_ami| jq ".Images[0]"".BlockDeviceMappings[0]"".Ebs"".SnapshotId" | awk -F "\"" {'print $2}')
ami_device_name=$(aws ec2 describe-images --image-ids $instance_ami | jq ".Images[0]"".BlockDeviceMappings[0]"".DeviceName"| awk -F "\"" '{print $2}')
echo "Instance snapshot id is $snapshot_id"
echo "Instance ami_device_name is $ami_device_name"
echo "aws ec2 run-instances --image-id $instance_ami --instance-type $instance_type --key-name $key --security-group-ids $security_group --subnet-id $subnet --block-device-mappings \"[{\\\"DeviceName\\\":\\\"$ami_device_name\\\",\\\"Ebs\\\":{\\\"DeleteOnTermination\\\":$delete_on_termination,\\\"SnapshotId\\\":\\\"$snapshot_id\\\",\\\"VolumeSize\\\":$storage_size,\\\"VolumeType\\\":\\\"$storage_type\\\"}}]\""
ipaddress=$(aws ec2 run-instances --image-id $instance_ami --instance-type $instance_type --key-name $key --security-group-ids sg-07f37a62 $security_group --subnet-id $subnet --block-device-mappings "[{\"DeviceName\":\"$ami_device_name\",\"Ebs\":{\"DeleteOnTermination\":$delete_on_termination,\"SnapshotId\":\"$snapshot_id\",\"VolumeSize\":$storage_size,\"VolumeType\":\"$storage_type\"}}]" | jq ".Instances[0]"".PrivateIpAddress" |  awk -F "\"" '{print $2}')
echo "Instance ipaddress is $ipaddress"
until aws ec2 describe-instances --filters "Name=private-ip-address,Values=$ipaddress" | jq ".Reservations[0]"".Instances[0]"".State"".Name" | grep running ; do sleep 1;done
echo "Instance is available"
instanceid=$(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$ipaddress" | jq ".Reservations[0]"".Instances[0]"".InstanceId" | awk -F "\"" '{print $2}')
echo "Instance_id is $instanceid"
until nc -z $ipaddress 22 | grep "succeeded"; do sleep 1;echo "waiting for ssh to come up";done
aws ec2 create-tags --resources $instanceid --tags Key=Name,Value=$instance_name
bundle exec knife bootstrap $ipaddress -x ubuntu --node-name $instance_name -E $instance_env -r "$runlist" -i ~/.ssh/$key --sudo
