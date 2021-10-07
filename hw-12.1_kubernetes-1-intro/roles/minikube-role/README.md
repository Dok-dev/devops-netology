Minikube role for ansible
=========

Role Variables
--------------
There is variables that you can redefine in your playbook.
```yaml
minikube_version: "1.23.2"
minikube_download_dir: "{{ x_ansible_download_dir | default(ansible_env.HOME + '/.ansible/tmp/downloads') }}"
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
      - minikube-role
```

License
-------

BSD

Author Information
------------------

Timofey Biryukov
