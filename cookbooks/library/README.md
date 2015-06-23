# Requirements
This is library cookbook, has functions and infrastructure support This is required for most of the functions required to get infrastructure going

#### Java Tools
CentOS Java Tools recipe is only used on Ambari cluster and installs various tools required for the same

To add a tool you need to edit  
``
java-tools.rb
``
under attributes
* Add a tool name in java_tools attributes
* After adding the tool name, create corresponding attributes
* Then run chef-client on all nodes on ambari cluster

