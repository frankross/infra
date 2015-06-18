
# Used by helper library to generate certificates/keys
override['openvpn']['key']['country']           = 'IN'
override['openvpn']['key']['province']          = 'DE'
override['openvpn']['key']['city']              = 'DE'
override['openvpn']['key']['org']               = 'emami'
override['openvpn']['key']['email']             = 'vipul@codeignition.co'

# Cookbook attributes
override['openvpn']['netmask']                  = '255.255.0.0'
override['openvpn']['configure_default_server'] = false
override['openvpn']['subnet']                   = "10.59.0.0"
override['openvpn']['gateway']                  = "54.169.56.89"
override['openvpn']['routes']                   = ["push 'route #{node['vpc']['cidr']} #{node['vpc']['netmask']}'"]
override["dns"]["server"]                       = "10.60.0.2"
