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


