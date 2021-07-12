# Домашнее задание «8.4 Создание собственных modules»

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`
    
	>**Выполнение:**    
```
vagrant@vagrant:~$ sudo apt install libffi-dev python-dev
vagrant@vagrant:~$ sudo apt install python3-venv
vagrant@vagrant:~$ mkdir test
vagrant@vagrant:~$ cd test
vagrant@vagrant:~/test$ git clone https://github.com/ansible/ansible.git
vagrant@vagrant:~/test$ cd ansible
vagrant@vagrant:~/test$ python3 -m venv venv
vagrant@vagrant:~/test/ansible$ . venv/bin/activate
(venv) vagrant@vagrant:~/test/ansible$ pip install -r requirements.txt
(venv) vagrant@vagrant:~/test/ansible$ . hacking/env-setup
(venv) vagrant@vagrant:~/test/ansible$ deactivate
```

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл.
	>**Выполнение:**    
```
vagrant@vagrant:~/test/ansible$ . venv/bin/activate && . hacking/env-setup
(venv) vagrant@vagrant:~/test/ansible$ cd lib/ansible/modules
(venv) vagrant@vagrant:~/test/ansible/lib/ansible/modules$ vim my_own_module.py
(venv) vagrant@vagrant:~/test/ansible/lib/ansible/modules$ chmod +x my_own_module.py
```
2. Наполнить его содержимым:
```python
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
Или возьмите данное наполнение из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
4. Проверьте module на исполняемость локально.
	>**Выполнение:**    
```
(venv) vagrant@vagrant:~/test/ansible$ touch payload.json
(venv) vagrant@vagrant:~/test/ansible$ echo "
{
  "ANSIBLE_MODULE_ARGS": {
     "name": "HelloWorld.txt",
     "path": "/tmp/module_test",
     "content": "Netology students",
     "rewrite": "False"
  }
}
" > payload.json
(venv) vagrant@vagrant:~/test/ansible$ python -m ansible.modules.my_own_module payload.json
{"changed": true, "original_message": "Successful created", "message": "goodbye", "invocation": {"module_args": {"name": "HelloWorld.txt", "path": "/tmp/module_test", "content": "Netology students", "rewrite": false, "new": false}}}
(venv) vagrant@vagrant:~/test/ansible$ cat /tmp/module_test/HelloWorld.txt
Netology students
(venv) vagrant@vagrant:~/test/ansible$ python -m ansible.modules.my_own_module payload.json
{"changed": false, "original_message": "HelloWorld.txt", "message": "goodbye", "invocation": {"module_args": {"name": "HelloWorld.txt", "path": "/tmp/module_test", "content": "Netology students", "rewrite": false, "new": false}}}
```
5. Напишите single task playbook и используйте module в нём.
	>**Выполнение:**    
```
(venv) vagrant@vagrant:~/test/ansible$ cat playbook.yml
---
- name: Create file whis some content
  hosts: localhost
  tasks:
  - name: run my_own_module
    my_own_module:
      name: "HelloWorld.txt"
      path: "/tmp/module_test"
      content: "Netology students\n"
      rewrite: False
    register: testout
  - name: print testout
    debug:
      msg: '{{ testout }}'
```
```
(venv) vagrant@vagrant:~/test/ansible$ ansible-playbook playbook.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create file whis some content] ****************************************************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [run my_own_module] ****************************************************************************************************************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [print testout] ********************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "changed": true,
        "failed": false,
        "message": "goodbye",
        "original_message": "Successful created"
    }
}

PLAY RECAP ******************************************************************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

# тестируем фреймворком
(venv) vagrant@vagrant:~/test/ansible$ ./hacking/test-module.py -m lib/ansible/modules/my_own_module.py
* including generated source, if any, saving to: /home/vagrant/.ansible_module_generated
* ansiballz module detected; extracted module source to: /home/vagrant/debug_dir
***********************************
RAW OUTPUT

{"failed": true, "msg": "missing required arguments: content, path", "invocation": {"module_args": {"name": "netology.txt", "rewrite": true, "new": false, "path": null, "content": null}}}


***********************************
PARSED OUTPUT
{
    "failed": true,
    "invocation": {
        "module_args": {
            "content": null,
            "name": "netology.txt",
            "new": false,
            "path": null,
            "rewrite": true
        }
    },
    "msg": "missing required arguments: content, path"
}
```
6. Проверьте через playbook на идемпотентность.
	>**Выполнение:**    
```
(venv) vagrant@vagrant:~/test/ansible$ ansible-playbook playbook.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create file whis some content] ****************************************************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [run my_own_module] ****************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [print testout] ********************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "changed": false,
        "failed": false,
        "message": "goodbye",
        "original_message": "HelloWorld.txt"
    }
}

PLAY RECAP ******************************************************************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
(venv) vagrant@vagrant:~/test/ansible$ deactivate
```
7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.my_own_collection`
	>**Выполнение:**    
```
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module$ ansible-galaxy collection init my_own_namespace.my_own_collection
- Collection my_own_namespace.my_own_collection was created successfully
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module$ cd my_own_namespace/my_own_collection

```
9. В данную collection перенесите свой module в соответствующую директорию.
	>**Выполнение:**    
```
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module/my_own_namespace/my_own_collection$ mkdir plugins/modules
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module/my_own_namespace/my_own_collection$ cp ~/test/ansible/lib/ansible/modules/my_own_module.py plugins/modules
```
10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module
	>**Выполнение:**   
	>https://github.com/Dok-dev/devops-netology/tree/main/hw-08.4_Ansible-4-module/playbook2/collections/ansible_collections/my_own_namespace/my_own_collection/roles/create_file
11. Создайте playbook для использования этой role.
12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
	>**Выполнение:**    
```
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module/my_own_namespace/my_own_collection$ ansible-galaxy collection build
Created collection for my_own_namespace.my_own_collection at /mnt/prime/hw-08.4_Ansible-4-module/my_own_namespace/my_own_collection/my_own_namespace-my_own_collection-1.0.0.tar.gz
```
14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.

15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
	>**Выполнение:**    
```
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module/playbook2$ ansible-galaxy collection install -p collections my_own_namespace-my_own_collection-1.0.0.tar.gz
Starting galaxy collection install process
[WARNING]: The specified collections path '/mnt/prime/hw-08.4_Ansible-4-module/playbook2/collections' is not part of the configured Ansible collections paths
'/home/vagrant/.ansible/collections:/usr/share/ansible/collections'. The installed collection won't be picked up in an Ansible run.
Process install dependency map
Starting collection install process
Installing 'my_own_namespace.my_own_collection:1.0.0' to '/mnt/prime/hw-08.4_Ansible-4-module/playbook2/collections/ansible_collections/my_own_namespace/my_own_collection'
my_own_namespace.my_own_collection:1.0.0 was installed successfully
```
16. Запустите playbook, убедитесь, что он работает.
	>**Выполнение:**    
```
vagrant@vagrant:/mnt/prime/hw-08.4_Ansible-4-module/playbook2$ ansible-playbook site.yml
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create file whis some content] ****************************************************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [my_own_namespace.my_own_collection.create_file : run my_own_module] ***************************************************************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [my_own_namespace.my_own_collection.create_file : print testout] *******************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "changed": true,
        "failed": false,
        "message": "goodbye",
        "original_message": "Successful created"
    }
}

PLAY RECAP ******************************************************************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
17. В ответ необходимо прислать ссылку на репозиторий с collection
	>**Ответ:**    
	>https://github.com/Dok-dev/ansible_collection

## Необязательная часть

1. Используйте свой полёт фантазии: Создайте свой собственный module для тех roles, что мы делали в рамках предыдущих лекций.
2. Соберите из roles и module отдельную collection.
3. Создайте новый репозиторий и выложите новую collection туда.

Если идей нет, но очень хочется попробовать что-то реализовать: реализовать module восстановления из backup elasticsearch.
