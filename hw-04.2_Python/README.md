# Домашнее задание «4.2. Использование Python для решения типовых DevOps задач»

**1 - задание.**    
Есть скрипт:    
```python
    #!/usr/bin/env python3
	a = 1
	b = '2'
	c = a + b
```
	* Какое значение будет присвоено переменной c?
	* Как получить для переменной c значение 12?
	* Как получить для переменной c значение 3?
	
**Решение:**    
В данном варианте при выполнении скрипта произойдет ошибка по несовпадению типов.    

Для получения c=='12':    
```python
a = '1'
b = '2'
c = a + b
```
Для получения c=='12':    
```python
a = 1
b = 2
c = a + b
```

---

**2 - задание.**    
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
    #!/usr/bin/env python3

    import os

	bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
	for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

```

**Решение:**    
```python
import os
import git

path = os.path.abspath(os.curdir)

bash_commands = ["cd " + path, "git status"]
try:
   result_os = os.popen(' && '.join(bash_commands)).read()
except git.GitError as e:
   print(e)
   exit(1)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = os.path.join(path, (result.replace('\tmodified:   ', '')))
        print(prepare_result)
```

---

**3 - задание.**    
Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

**Решение:**    
```python
import os
import sys
import git

try:
 path = sys.argv[1]
except Exception:
  print('Input path to git repository')
  path = input()

if os.path.exists(path):
    try:
        git.Repo(path).git_dir

        bash_commands = ["cd " + path, "git status"]
        try:
           result_os = os.popen(' && '.join(bash_commands)).read()
        except git.exc.GitError as e:
           print(e)
           exit(1)
        for result in result_os.split('\n'):
            if result.find('modified') != -1:
               prepare_result = os.path.join(path, (result.replace('\tmodified:   ', '')))
               print(prepare_result)
    except git.exc.InvalidGitRepositoryError:
        print(f'Git repository not found in {path} !')
else:
    print('Path not exists!')
```

**4 - задание.**    
Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

**Решение:**    
```python
import socket

lookupList = []

# Получаем массив строк из файла
with open('hosts.txt', 'rt') as file:
    line = file.readline()
    # Разбираем строки, проверяем соотвествие IP и делаем номерованый словарь из хостов с ip
    while line:
        line = line.split(' ')
        if len(line) > 1:
        # делаем попытку лукапа доменного имени
            try:
                newIp = socket.gethostbyname(line[0])
            except socket.SO_ERROR:
                print('Lookup error!')

            # проверяем соотвествие IP, выводим ошибки и добавляем правильный вариант в список
            if newIp != line[1].strip():
                print(f'[ERROR] {line[0]} IP mismatch: {line[1].strip()} {newIp}')
            lookupList.append(line[0] + ' ' + newIp)
        line = file.readline()

# обновления файла с хостами
with open('hosts.txt', 'wt') as file:
    for line in lookupList:
        file.write(line + '\n')
```

---

**Дополнительное задание (со звездочкой).**    
к получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

**Решение:**    
```python
import json
import requests

# Github username
username = "Dok-dev"
#password = input('Введите пароль от репозитория: ')
password = '******'

# authenticate to github
g = Github(username, password)
repo = g.get_repo("Dok-dev/devops-netology")


URL = 'https://api.github.com/repos/Dok-dev/devops-netology/pulls'

path = {
    'owner': 'Dok-dev',
    'repo': 'devops-netology'
}

data = {
    'head': 'test',
    'base': 'main'
}

headers = {"Content-Type": "application/json"}

res = requests.post(URL, auth=(username, password), headers=headers, data=json.dumps(data), json=json)
print(res)
```
Получаю <Response [404]>, почему непонятно. В документации URL так описан - `/repos/{owner}/{repo}/pulls`. Вроде все правильно.

---

**ОТЗЫВ ПРЕПОДАВАТЕЛЯ**

Петр Шило    
21 марта 2021 17:41

*Здравствуйте, Тимофей.

Спасибо за выполненное задание. Все сделано верно, в последнем задании возможно стоит проверить аутентификацию. Если возникнут вопросы, пишите в слак. Успехов в дальнейшем прохождении курса.*
