```bash
Using username "vagrant".
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun 28 Feb 2021 04:04:18 PM UTC

  System load:  0.46              Processes:             105
  Usage of /:   2.4% of 61.31GB   Users logged in:       0
  Memory usage: 13%               IPv4 address for eth0: 192.168.17.151
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Sun Feb 28 15:28:15 2021
vagrant@netology3:~$ sudo -i

root@netology3:~# hostnamectl set-hostname netology4

root@netology4:~# ip addr add 192.168.17.200/32 dev lo label lo:200

root@netology4:~# ip -4 addr show lo | grep inet
    inet 127.0.0.1/8 scope host lo
    inet 192.168.17.200/32 scope global lo:200

root@netology4:~# sysctl -w net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_ignore = 1

root@netology4:~# sysctl -w net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.all.arp_announce = 2
root@netology4:~#
```