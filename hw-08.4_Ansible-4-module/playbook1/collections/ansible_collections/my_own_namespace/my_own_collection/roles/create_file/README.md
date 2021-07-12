Create file with some content
=========

Simple create file with preset name, path and content.

Role Variables
--------------
There is four variables that you can redefine in your playbook.
```yaml
  file_name: "HelloWorld.txt"    #Define the file name.
  path_to_file: "/tmp/module_test"  #Specifies the file creation path.
  file_content: "Netology students\n"  #Defines the contents of the file.
  rewrite_perm: False  #Defines rewrite file if exists or no.
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
    - create_file
```

License
-------

BSD

Author Information
------------------

Netology Students
