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
#username = "Dok-dev"
#password = input('Введите пароль от репозитория: ')
#password = ''

# authenticate to github
#g = Github(username, password)
#repo = g.get_repo("Dok-dev/devops-netology")

#URL = 'https://api.github.com/users/Dok-dev'
#res = requests.get(URL)
#print(res)

URL = 'https://api.github.com/repos/Dok-dev/devops-netology/pulls'
params = {
    'owner': 'Dok-dev',
    'repo': 'devops-netology',
    'head': 'head',
    'base': 'base'
}

res = requests.post(URL, params)
print(res)