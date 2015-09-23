## Adding User to VPN

1. Log into 54.169.56.89
2. `sudo su`
3. `cd /etc/openvpn/easy-rsa/`
4. `source ./vars`
5. rake client name="<user>" gateway="54.169.56.89"

The openvpn keys will be generated into `/tmp` directory.

scp them to your local and share with the user.
