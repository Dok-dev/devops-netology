```bash
Using username "vagrant".
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun 28 Feb 2021 04:02:16 PM UTC

  System load:  0.02              Processes:             112
  Usage of /:   2.5% of 61.31GB   Users logged in:       1
  Memory usage: 14%               IPv4 address for eth0: 192.168.17.150
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Sun Feb 28 16:00:27 2021 from 192.168.17.2
vagrant@netology3:~$ sudo -i

root@netology3:~# ip addr add 192.168.17.200/32 dev lo label lo:200

root@netology3:~# sysctl -w net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_ignore = 1

root@netology3:~# sysctl -w net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.all.arp_announce = 2
root@netology3:~#
```
