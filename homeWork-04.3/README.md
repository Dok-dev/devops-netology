# Домашнее задание «4.3. Языки разметки JSON и YAML»

**1 - задание.**    
Мы выгрузили JSON, который получили через API запрос к нашему сервису:    
```json
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip : 71.78.22.43
        }
    ]
}
```


**Исправленный:**       
```json
{
  "info" : "Sample JSON output from our service\t",
  "elements": [
    {
      "name": "first",
      "type": "server",
      "port": 7175
    },
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"
    }
  ]
}
```

---

**2 - задание.**    
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

**Решение:**    
```python
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

# обновления файлов с хостами
with open('hosts.txt', 'wt') as file:
    for line in lookupList:
        file.write(line + '\n')

with open('hosts.json', 'wt') as file:
        json.dump(jsonList, fp=file, indent=2)

with open('hosts.yaml', 'wt') as file:
    yaml.dump(jsonList, file, default_flow_style=False, explicit_start=True, explicit_end=True)
```

---

**Дополнительное задание (со звездочкой).**    
Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:

*    Принимать на вход имя файла
*    Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
*    Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
*    Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
*    При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
*    Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов


**Решение:**    
```python
import yaml
import json
from sys import argv

try:
 fileName = argv[1]
except IndexError:
    print('[ERROR] You must specify the file name for parsing')

# Пробуем распарсить как JSON
with open(fileName, 'rt') as file:
    try:
      hostList = json.load(file)
      jsonFormat = True
      fileName = fileName.split('.', 2)[0] + '.yaml'
      with open(fileName, 'wt') as newFile:
          yaml.dump(hostList, newFile, default_flow_style=False, explicit_start=True, explicit_end=True)
      print('converted to ' + fileName + ' successful')

    except json.JSONDecodeError as error:
        jsonFormat = False
        jsonError = str(error)

# если с JSON все плохо делаем заход на YAML
if not jsonFormat:
    with open(fileName, 'rt') as file:
        try:
            hostList = yaml.load(file, Loader=yaml.BaseLoader)
            fileName = fileName.split('.', 2)[0] + '.json'
            with open(fileName, 'wt') as newFile:
                json.dump(hostList, fp=newFile, indent=2)
            print('converted to ' + fileName + ' successful')
        #Если и с YAML дело дрянь - вываливаем накопившиеся претензии и выходим с ошибкой
        except yaml.YAMLError as exc:
            print("[ERROR] The file format does not match the correct json or yaml\n")
            print('If JSON errors:\n' + jsonError + '\n')
            if hasattr(exc, 'problem_mark'):
                print('If YAML errors::')
                print(exc.__str__())
            exit(1)
```
