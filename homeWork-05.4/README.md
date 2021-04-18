# Домашнее задание «5.4. Практические навыки работы с Docker»

## Задание 1 

В данном задании вы научитесь изменять существующие Dockerfile, адаптируя их под нужный инфраструктурный стек.

Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.

```text
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:vincent-c/ponysay && \
    apt-get update
 
RUN apt-get install -y ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

Для получения зачета, вам необходимо предоставить:
- Написанный вами Dockerfile    
**Ответ:**    
```text
FROM archlinux:latest

RUN pacman -Sy

RUN ppacman -S --noconfirm ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

- Скриншот вывода командной строки после запуска контейнера из вашего базового образа    
**Ответ:**    
![1](1.png)

- Ссылку на образ в вашем хранилище docker-hub    
**Ответ:**    
https://hub.docker.com/r/0dok0/archlinux_ponysay

---

## Задание 2

В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в `dockerhub.io` и посмотрим логи этих контейнеров.

- Составьте 2 Dockerfile:

    - Общие моменты:
        - Образ должен запускать [Jenkins server](https://www.jenkins.io/download/)
        
    - Спецификация первого образа:
        - Базовый образ - [amazoncorreto](https://hub.docker.com/_/amazoncorretto)
        - Присвоить образу тэг `ver1` 
    
    - Спецификация второго образа:
        - Базовый образ - [ubuntu:latest](https://hub.docker.com/_/ubuntu)
        - Присвоить образу тэг `ver2` 

- Соберите 2 образа по полученным Dockerfile
- Запустите и проверьте их работоспособность
- Опубликуйте образы в своём dockerhub.io хранилище

Для получения зачета, вам необходимо предоставить:
- Наполнения 2х Dockerfile из задания    
**Ответ:**   

- Скриншоты логов запущенных вами контейнеров (из командной строки)    
**Ответ:**   

- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)    
**Ответ:**   

- Ссылки на образы в вашем хранилище docker-hub    
**Ответ:**   


код:
```bash

```


---

## Задание 3 

В данном задании вы научитесь:
- объединять контейнеры в единую сеть
- исполнять команды "изнутри" контейнера

Для выполнения задания вам нужно:
- Написать Dockerfile: 
    - Использовать образ https://hub.docker.com/_/node как базовый
    - Установить необходимые зависимые библиотеки для запуска npm приложения https://github.com/simplicitesoftware/nodejs-demo
    - Выставить у приложения (и контейнера) порт 3000 для прослушки входящих запросов  
    - Соберите образ и запустите контейнер в фоновом режиме с публикацией порта

- Запустить второй контейнер из образа ubuntu:latest 
- Создайть `docker network` и добавьте в нее оба запущенных контейнера
- Используя `docker exec` запустить командную строку контейнера `ubuntu` в интерактивном режиме
- Используя утилиту `curl` вызвать путь `/` контейнера с npm приложением  

Для получения зачета, вам необходимо предоставить:
- Наполнение Dockerfile с npm приложением    
**Ответ:**    
```text
FROM node
ADD https://github.com/simplicitesoftware/nodejs-demo/archive/master.zip /
RUN unzip master.zip && \
    cd /nodejs-demo-master && \
    npm install
EXPOSE 3000
WORKDIR "/nodejs-demo-master"
CMD ["npm", "start", "0.0.0.0"]
```

- Скриншот вывода вызова команды списка docker сетей (docker network cli)    
**Ответ:**    
```text
root@vagrant:/home/vagrant# docker network ls
NETWORK ID     NAME           DRIVER    SCOPE
1e653389a6d5   bridge         bridge    local
bb96adaef5ae   host           host      local
65fac76d2be4   node_network   bridge    local
55601b752449   none           null      local
```
```text
root@vagrant:/home/vagrant# docker network inspect node_network
[
    {
        "Name": "node_network",
        "Id": "65fac76d2be4d4808f2ccfea938129829e2efe8427f97031da6a1c14887d046d",
        "Created": "2021-04-18T18:07:36.299704556Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "169a19a973f83287f4ffa724b17997fef0387560e234dc9e0bd934dfee7db9a2": {
                "Name": "ubuntu",
                "EndpointID": "743c438f28cbbef3cd8f06afd71224b74c740c49890021968010e3ebd304425e",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            },
            "507c9a08fda398fe183e09d7572702fb4489dd089e237e615d8266d8d50b3d65": {
                "Name": "node",
                "EndpointID": "76c656cf5f09f273d851c701a345a6631ff1e63624d30f873aab9d4af70896dc",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

- Скриншот вызова утилиты curl с успешным ответом    
**Ответ:**    
![3](3.1.png)
![3](3.2.png)

код:
```bash
# создаем image по DockerFile node и запускаем контейнер
docker build -t 0dok0/node -f node .
docker run -d -ti --name node --publish=3000:3000 0dok0/node

# создаем сеть и подключаем контейнер к сети
docker network create node_network
docker network connect node_network node

# создаем контейнер ubuntu и тоже подключаем его к сети
docker run -d -ti -v /home/vagrant/docker:/tmp/docker --name ubuntu ubuntu:18.04 bash
docker network connect node_network ubuntu

# устанавливаем в контейнере curl и проверяем
docker exec -ti ubuntu bash
apt-get update
apt-get install curl
curl 172.18.0.2:3000
```

