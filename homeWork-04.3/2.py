import socket
import yaml
import json

lookupList = []
jsonList = []

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
            jsonList.append({line[0]: newIp})
        line = file.readline()

# обновления файла с хостами
with open('hosts.txt', 'wt') as file:
    for line in lookupList:
        file.write(line + '\n')

with open('hosts.json', 'wt') as file:
        json.dump(jsonList, fp=file, indent=2)

with open('hosts.yaml', 'wt') as file:
    yaml.dump(jsonList, file, default_flow_style=False, explicit_start=True, explicit_end=True)