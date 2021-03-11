# Домашнее задание «4.2. Использование Python для решения типовых DevOps задач»

**1 - задание.**

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

```python
import os
import git

path = os.path.abspath(os.curdir)

bash_commands = ["cd " + path, "git status"]
try:
   result_os = os.popen(' && '.join(bash_commands)).read()
except git.GitError as e:
   print(e)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = os.path.join(path, (result.replace('\tmodified:   ', '')))
        print(prepare_result)
```

---

**3 - задание.**

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
        path = git.Repo(path).git_dir
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