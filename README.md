# network-configurator

A small utility for editing network settings.

This application changes the values of IP, DNS, Gateway, Netmask and Hostname for the specified MAC address.

It can be used to automate routine tasks related to configuring network interfaces in Windows: after multiple deployments of OS backups, editing existing settings, and sorting PCs by hostname in networks/subnets.


## How to use?
Settings are edited based on the MAC address of a specific network adapter. To obtain all MAC addresses of devices in the local network/subnet, it is recommended to use the [arp-scan](https://linux.die.net/man/1/arp-scan).

Preparation steps:

1.Clone the repository.

2.Generate a CSV file net_preset.dat with a '\t' delimiter, which contains new network settings for the specified MAC addresses, and place it in the root of the project. The file should have columns: NUM, IP, MAC, MASK, GATEWAY, DNS1, DNS2, HOSTNAME:

```
NUM	IP	        MAC	            MASK	        GATEWAY	        DNS1	    DNS2	    HOSTNAME
1	192.168.1.1	00:11:22:33:44:55	255.255.255.0	192.168.1.254	8.8.8.8	    8.8.4.4	    host1
2	192.168.1.2	00:11:22:33:44:56	255.255.255.0	192.168.1.254	8.8.8.8	    8.8.4.4	    host2
3	192.168.1.3	00:11:22:33:44:57	255.255.255.0	192.168.1.254	8.8.8.8	    8.8.4.4	    host3
```
3.Run init_powershell.bat with administrator privileges.

# License
MIT