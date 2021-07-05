# Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда
# разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими
# изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request
# (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим
# максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с
# локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением,
# которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить
# к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального
# репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не
# будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором
# применяются наши изменения.

# Use https://pygithub.readthedocs.io/en/latest/examples/PullRequest.html#create-a-new-pull-request
# https://pygithub.readthedocs.io/en/latest/github_objects/PullRequest.html
# Use https://docs.github.com/en/free-pro-team@latest/rest/reference/pulls#create-a-pull-request
# pip3 install PyGithub requests
# pip install httpretty
# pip install requests

import os
import base64
from github import Github
from getpass import getpass

rep_path = r'c:\users\tim\devops-netology'
request_msg = input() #переделать в параметр запуска

bash_commands = ['cd ' + rep_path, 'git status']
result_os = os.popen(' && '.join(bash_commands)).read()
#print(result_os)


# Github username
username = "Dok-dev"
#password = input('Введите пароль от репозитория: ')
password = ''

# authenticate to github
g = Github(username, password)
repo = g.get_repo("Dok-dev/devops-netology")
#print(list(repo.get_branches()))
body = '''
SUMMARY
Change HTTP library used to send requests

TESTS
  - [x] Send 'GET' request
  - [x] Send 'POST' request with/without body
'''
pr = repo.create_pull(title="Use 'requests' instead of 'httplib'", body=body, head="develop", base="main")
pr
Github.PullRequest(title="Use 'requests' instead of 'httplib'", number=664)