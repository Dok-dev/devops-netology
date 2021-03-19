import socket
import yaml
import json

lookupList = []
jsonList = []

# Получаем массив строк из файла
with open('hosts.json', 'rt') as file:
    try:
      hostList = json.load(file)
      print(type(hostList))
    except json.JSONDecodeError:
        print('Ошибка формата hosts.json')

    for host in hostList:
        try:
            # делаем попытку лукапа доменного имени
            newIp = socket.gethostbyname(host['host'])
            host['ip'] = newIp
        except socket.SO_ERROR:
            print('Lookup error!')


# обновления файла с хостами

with open('hosts.json', 'wt') as file:
        json.dump(jsonList, fp=file, indent=2)

with open('hosts.yaml', 'wt') as file:
    yaml.dump(jsonList, file, default_flow_style=False, explicit_start=True, explicit_end=True)