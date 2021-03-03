```bash
root@netology2:~# apt -y install ipvsadm keepalived

###### наверное будет работать и без этого ######
root@netology2:~# ipvsadm -A -t 192.168.17.200:80 -s rr
root@netology2:~# ipvsadm -a -t 192.168.17.200:80 -r 192.168.17.150:80 -g -w 1
root@netology2:~# ipvsadm -a -t 192.168.17.200:80 -r 192.168.17.151:80 -g -w 1
#################################################

vim /etc/keepalived/keepalived.conf
```
```text
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    track_interface {
        eth0
    }
    virtual_router_id 33
    priority 50
    advert_int 1
    authentication {
                auth_type PASS
        auth_pass super_secret
        }
        virtual_ipaddress {
                192.168.17.200/24 dev eth0
        }
}

virtual_server 192.168.17.200 80 {
    delay_loop 10
    lvs_sched rr
    lvs_method DR
    persistence_timeout 5
    protocol TCP

    real_server 192.168.17.150 80 {
        weight 50
        TCP_CHECK {
            connect_timeout 3
        }
    }

    real_server 192.168.17.151 80 {
        weight 50
        TCP_CHECK {
            connect_timeout 3
        }
    }

}
```

```bash
root@netology2:~# systemctl start ipvsadm
root@netology2:~# systemctl enable ipvsadm
ipvsadm.service is not a native service, redirecting to systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable ipvsadm

root@netology2:~# systemctl start keepalived
root@netology2:~# systemctl enable keepalived
Synchronizing state of keepalived.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable keepalived

root@netology2:~# reboot
```