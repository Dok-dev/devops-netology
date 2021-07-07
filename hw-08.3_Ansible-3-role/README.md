# Домашнее задание «8.3 Работа с Roles»

## Подготовка к выполнению
1. Создайте два пустых публичных репозитория в любом своём проекте: elastic-role и kibana-role.
2. Скачайте [role](https://github.com/netology-code/mnt-homeworks/blob/master/08-ansible-03-role/roles) из репозитория с домашним заданием и перенесите его в свой репозиторий elastic-role.
3. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 
4. Установите molecule: `pip3 install molecule`
5. Добавьте публичную часть своего ключа к своему профилю в github.
    >**Выполнение:**   
```
vagrant@vagrant:~/.ssh$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): git_rsa
Enter passphrase (empty for no passphrase):    # blank
Enter same passphrase again:
Your identification has been saved in git_rsa
Your public key has been saved in git_rsa.pub

vagrant@vagrant:~/.ssh$ cat git_rsa.pub       # to add on https://github.com/settings/keys
```

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana и написать playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:
   ```yaml
   ---
     - src: git@github.com:netology-code/mnt-homeworks-ansible.git
       scm: git
       version: "1.0.1"
       name: java 
   ```
2. При помощи `ansible-galaxy` скачать себе эту роль. Запустите  `molecule test`, посмотрите на вывод команды.
    >**Выполнение:**   
```
# Установка ролей посредством разрешения зависимостей в requirements.yml
vagrant@vagrant:/mnt/prime/hw-08.3_Ansible-3-role/playbook$ ansible-galaxy install -r requirements.yml
Starting galaxy role install process
- extracting java to /home/vagrant/.ansible/roles/java
- java (1.0.1) was installed successfully

vagrant@vagrant:/mnt/prime/hw-08.3_Ansible-3-role/playbook$ cd /home/vagrant/.ansible/roles/java

# Установим дравер докера, который нужен для тестирования этой роли
vagrant@vagrant:~/.ansible/roles/java$ sudo pip3 install molecule-docker

vagrant@vagrant:~/.ansible/roles/java$ sudo molecule test -s default
```
3. Перейдите в каталог с ролью elastic-role и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.
4. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
5. Создайте новый каталог с ролью при помощи `molecule init role --driver-name docker kibana-role`. Можете использовать другой драйвер, который более удобен вам.
    >**Выполнение:**   
```
vagrant@vagrant:/mnt/devops/roles$ molecule init role --driver-name docker kibana-role
INFO     Initializing new role kibana-role...
No config file found; using defaults
- Role kibana-role was created successfully
INFO     Initialized role in /mnt/devops/roles/kibana-role successfully.
```
6. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. Проведите тестирование на разных дистрибитивах (centos:7, centos:8, ubuntu).
7. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.
8. Добавьте roles в `requirements.yml` в playbook.
    >**Выполнение:**   
```
Starting galaxy role install process
- mnt-homeworks-ansible (1.0.1) is already installed, skipping.
- extracting kibana to /home/vagrant/.ansible/roles/kibana
- kibana (1.0.0) was installed successfully
- extracting elastic to /home/vagrant/.ansible/roles/elastic
- elastic (1.0.0) was installed successfully
```
9. Переработайте playbook на использование roles.
10. Выложите playbook в репозиторий.
11. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.
    >**Ответ:**   
    >https://github.com/Dok-dev/elastic-role    
    >https://github.com/Dok-dev/kibana-role    
    >https://github.com/Dok-dev/devops-netology/tree/main/hw-08.2_Ansible-2-playbook/playbook    

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что elastic запущен и возвращает успешный статус по API, web-интерфейс kibana отвечает без кодов ошибки, logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`.
4. Убедитесь в работоспособности своего стека. Возможно, потребуется тестировать все роли одновременно.
5. Выложите свои roles в репозитории. В ответ приведите ссылки.