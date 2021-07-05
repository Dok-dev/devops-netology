import os
import requests
import httpretty
import json
import requests
from pprint import pprint
from github import Github
from github import PullRequest
from getpass import getpass


from github.PullRequest import PullRequest

#rep_path = r'c:\users\tim\devops-netology'
#request_msg = input() #переделать в параметр запуска

#bash_commands = ['cd ' + rep_path, 'git commit -m ''']
#result_os = os.popen(' && '.join(bash_commands)).read()
#print(result_os)


# Github username
username = "Dok-dev"
#password = input('Введите пароль от репозитория: ')
password = ''

# authenticate to github
g = Github(username, password)
repo = g.get_repo("Dok-dev/devops-netology")

URL = 'https://api.github.com/repos/Dok-dev/devops-netology/pulls'
#params1 = {
#    'owner': 'Dok-dev',
#    'repo': 'devops-netology'
#}

#res = requests.get(URL, params1)
#print(res.text)

# URL = 'https://api.github.com/repos/Dok-dev/devops-netology/pulls'
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

#Можете показать работающий пример POST на github API? По какой-то причине всегда получаю <Response [404]>. Хотя по документации все верно вроде бы. При этом с GET проблем нету.