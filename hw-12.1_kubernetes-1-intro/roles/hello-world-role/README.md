Logstash
=========

Simple download binaries from official website and install Logstash.

Role Variables
--------------
There is only two variables that you can redefine in your playbook.
```yaml
logstash_version: "7.13.2"
logstash_home: "/opt/logstash/{{ logstash_version }}"
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
      - logstash
```

License
-------

BSD

Author Information
------------------

Netology Students
