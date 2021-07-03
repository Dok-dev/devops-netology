# Домашнее задание «8.2 Работа с Playbook»


## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
    >**Выполнение:**   
```
vagrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ ansible-lint
WARNING  Listing 7 violation(s) that are fatal
risky-file-permissions: File permissions unset or incorrect
site.yml:9 Task/Handler: Upload .tar.gz file containing binaries from local storage

risky-file-permissions: File permissions unset or incorrect
site.yml:16 Task/Handler: Ensure installation dir exists

risky-file-permissions: File permissions unset or incorrect
site.yml:32 Task/Handler: Export environment variables

risky-file-permissions: File permissions unset or incorrect
site.yml:52 Task/Handler: Create directrory for Elasticsearch

risky-file-permissions: File permissions unset or incorrect
site.yml:67 Task/Handler: Set environment Elastic

risky-file-permissions: File permissions unset or incorrect
site.yml:87 Task/Handler: Create directrory for Kibana

risky-file-permissions: File permissions unset or incorrect
site.yml:102 Task/Handler: Set environment Kibana

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental
```
    > После установки прав на файлы (mode):
```
vagrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ ansible-lint
vagrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ 
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
    >**Выполнение:**   
```
agrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ ansible-playbook site.yml -i inventory/prod.yml --check
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [Install Java] ******************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Set facts for Java 11 vars] ****************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload .tar.gz file containing binaries from local storage] ********************************************************************************************************************************
ok: [elasticsearch]

TASK [Ensure installation dir exists] ************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract java in the installation directory] ************************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Export environment variables] **************************************************************************************************************************************************************
changed: [elasticsearch]

PLAY [Install Elasticsearch] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ***********************************************************************************************************************************************
changed: [elasticsearch]

TASK [Create directrory for Elasticsearch] *******************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] ***************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Set environment Elastic] *******************************************************************************************************************************************************************
changed: [elasticsearch]

PLAY [Install Kibana] ****************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Kibana from remote URL] ******************************************************************************************************************************************************
changed: [elasticsearch]

TASK [Create directrory for Kibana] **************************************************************************************************************************************************************
changed: [elasticsearch]

TASK [Extract Kibana in the installation directory] **********************************************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [elasticsearch]: FAILED! => {"changed": false, "msg": "dest '/opt/kibana/7.13.2' must be an existing dir"}

PLAY RECAP ***************************************************************************************************************************************************************************************
elasticsearch              : ok=12   changed=5    unreachable=0    failed=1    skipped=2    rescued=0    ignored=0
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
    >**Выполнение:**   
```
vagrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ ansible-playbook site.yml -i inventory/prod.yml --diff
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [Install Java] ******************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Set facts for Java 11 vars] ****************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload .tar.gz file containing binaries from local storage] ********************************************************************************************************************************
ok: [elasticsearch]

TASK [Ensure installation dir exists] ************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract java in the installation directory] ************************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Export environment variables] **************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
-    "mode": "0644",
+    "mode": "0755",
     "path": "/etc/profile.d/jdk.sh"
 }

changed: [elasticsearch]

PLAY [Install Elasticsearch] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ***********************************************************************************************************************************************
changed: [elasticsearch]

TASK [Create directrory for Elasticsearch] *******************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] ***************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Set environment Elastic] *******************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
-    "mode": "0644",
+    "mode": "0755",
     "path": "/etc/profile.d/elk.sh"
 }

changed: [elasticsearch]

PLAY [Install Kibana] ****************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Kibana from remote URL] ******************************************************************************************************************************************************
changed: [elasticsearch]

TASK [Create directrory for Kibana] **************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/kibana/7.13.2",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elasticsearch]

TASK [Extract Kibana in the installation directory] **********************************************************************************************************************************************
changed: [elasticsearch]

TASK [Set environment Kibana] ********************************************************************************************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-2605eu0zcmeu/tmpw_gz72tx/kibana.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KIBANA_HOME=/opt/kibana/7.13.2
+export PATH=$PATH:$KIBANA_HOME/bin
\ No newline at end of file

changed: [elasticsearch]

PLAY RECAP ***************************************************************************************************************************************************************************************
elasticsearch              : ok=14   changed=7    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
    >**Выполнение:**   
```
vagrant@vagrant:/mnt/prime/hw-08.2_Ansible-2-playbook/playbook$ ansible-playbook site.yml -i inventory/prod.yml --diff
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [Install Java] ******************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Set facts for Java 11 vars] ****************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload .tar.gz file containing binaries from local storage] ********************************************************************************************************************************
ok: [elasticsearch]

TASK [Ensure installation dir exists] ************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract java in the installation directory] ************************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Export environment variables] **************************************************************************************************************************************************************
ok: [elasticsearch]

PLAY [Install Elasticsearch] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ***********************************************************************************************************************************************
ok: [elasticsearch]

TASK [Create directrory for Elasticsearch] *******************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] ***************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Set environment Elastic] *******************************************************************************************************************************************************************
ok: [elasticsearch]

PLAY [Install Kibana] ****************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Kibana from remote URL] ******************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Create directrory for Kibana] **************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract Kibana in the installation directory] **********************************************************************************************************************************************
skipping: [elasticsearch]

TASK [Set environment Kibana] ********************************************************************************************************************************************************************
ok: [elasticsearch]

PLAY RECAP ***************************************************************************************************************************************************************************************
elasticsearch              : ok=13   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

## Необязательная часть

1. Приготовьте дополнительный хост для установки logstash.
2. Пропишите данный хост в `prod.yml` в новую группу `logstash`.
3. Дополните playbook ещё одним play, который будет исполнять установку logstash только на выделенный для него хост.
4. Все переменные для нового play определите в отдельный файл `group_vars/logstash/vars.yml`.
5. Logstash конфиг должен конфигурироваться в части ссылки на elasticsearch (можно взять, например его IP из facts или определить через vars).
6. Дополните README.md, протестируйте playbook, выложите новую версию в github. В ответ предоставьте ссылку на репозиторий.
    >**Ответ:**   
    >https://github.com/Dok-dev/devops-netology/tree/main/hw-08.1_Ansible-01-base/playbook