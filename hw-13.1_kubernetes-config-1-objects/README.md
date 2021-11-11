# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных (пример можно найти в папке 13-kubernetes-config).

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* ~~под содержит в себе 3 контейнера — фронтенд, бекенд, базу;~~ 2 пода содержат в себе 3 контейнера — 1 под: фронтенд, бекенд — 2 под: базу;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

> **Выполнение:**    
> 
> Создадим namespace `stage`:
> ```console   
> ubuntu@node1:~$ kubectl create namespace stage
> namespace/stage created
> ```
>
> Подготовим файл для деплоймента двух подов:
> ```console   
> vagrant@vagrant:~$ vim stage_deploy.yml
> ```
> ```yaml
> # Деплоймент фронтенда и бэкенда в один под
> ---
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: frontend-backend-dpl
>   namespace: stage
>   labels:
>     app: coolapp
> spec:
>   replicas: 1
>   selector:
>     matchLabels:
>       app: coolapp
>   template:
>     metadata:
>       labels:
>         app: coolapp
>     spec:
>       containers:
>       - name: frontend
>         image: 0dok0/kubernetes-config_backend
>         ports:
>         - containerPort: 80
>       - name: backend
>         image: 0dok0/kubernetes-config_frontend
>         ports:
>         - containerPort: 9000
>
> # Деплоймент базы в StatefulSet под
> ---
> apiVersion: apps/v1
> kind: StatefulSet
> metadata:
>   name: db-dpl
>   namespace: stage
> spec:
>   selector:
>     matchLabels:
>       app: db
>   serviceName: "db-srv"
>   replicas: 1
>   template:
>     metadata:
>       labels:
>         app: db
>     spec:
>       terminationGracePeriodSeconds: 10
>       containers:
>       - name: db
>         image: postgres:13-alpine
>         ports:
>         - containerPort: 5432
>         env:
>           - name: POSTGRES_PASSWORD
>             value: postgres
>           - name: POSTGRES_USER
>             value: postgres
>           - name: POSTGRES_DB
>             value: news
> ```
>
> Разместим deployment:
> ```console 
> vagrant@vagrant:~$ kubectl create -f stage_deploy.yml -n stage
> deployment.apps/frontend-backend-dpl created
> statefulset.apps/db-dpl created
> ```
> 
> Проверим что получилось:    
>![13-01-01](1.png)

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

> **Выполнение:**    
> 
> Создадим namespace `production`:
> ```console   
> ubuntu@node1:~$ kubectl create namespace production
> namespace/production created
> ```
>
> Подготовим файл для нового деплоймента - 3х подов и 3х сервисов:
> ```console   
> vagrant@vagrant:~$ vim production_deploy.yml
> ```  
> ```yaml
> # Деплоймент базы в StatefulSet под
> ---
> apiVersion: apps/v1
> kind: StatefulSet
> metadata:
>   name: db-dpl
>   namespace: production
> spec:
>   selector:
>      matchLabels:
>        app: db
>   serviceName: "db-srv"
>   replicas: 1
>   template:
>      metadata:
>        labels:
>          app: db
>      spec:
>        terminationGracePeriodSeconds: 10
>        containers:
>        - name: db
>          image: postgres:13-alpine
>          ports:
>          - containerPort: 5432
>          env:
>            - name: POSTGRES_PASSWORD
>              value: postgres
>            - name: POSTGRES_USER
>              value: postgres
>            - name: POSTGRES_DB
>              value: news
>
> # Сервис для базы
> ---
> apiVersion: v1
> kind: Service
> metadata:
>   name: db-srv
>   namespace: production
> spec:
>   selector:
>      app: db
>   ports:
>      - protocol: TCP
>        port: 5432
>        targetPort: 5432>              
>
> # Деплоймент бэкенда в отдельный под с сервисом БД в окружении
> ---
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: backend-dpl
>   namespace: production
>   labels:
>      app: backend
> spec:
>   replicas: 1
>   selector:
>      matchLabels:
>        app: backend
>   template:
>      metadata:
>        labels:
>          app: backend
>      spec:
>        containers:
>        - name: backend
>          image: 0dok0/kubernetes-config_backend
>          ports:
>          - containerPort: 9000
>          env:
>            - name: DATABASE_URL
>              value: postgres://postgres:postgres@db-srv:5432/news
>
> # Сервис бэкенда
> ---
> apiVersion: v1
> kind: Service
> metadata:
>   name: backend-srv
>   namespace: production
> spec:
>   selector:
>      app: backend
>   ports:
>      - protocol: TCP
>        port: 9000
>        targetPort: 9000
>
> # Деплоймент фронтенда в отдельный под с сервисом бэкенда в окружении
> ---
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: frontend-dpl
>   namespace: production
>   labels:
>      app: frontend
> spec:
>   replicas: 1
>   selector:
>      matchLabels:
>        app: frontend
>   template:
>      metadata:
>        labels:
>          app: frontend
>      spec:
>        containers:
>        - name: frontend
>          image: 0dok0/kubernetes-config_frontend
>          ports:
>          - containerPort: 80
>          env:
>            - name: BASE_URL
>              value: http://backend:9000
>
> # Сервис фронтенда
> ---
> apiVersion: v1
> kind: Service
> metadata:
>   name: frontend-srv
>   namespace: production
> spec:
>   selector:
>      app: frontend
>   ports:
>      - name: web
>        protocol: TCP
>        port: 8000
>        targetPort: 80
> ```
>
> Разместим deployment:
> ```console 
> vagrant@vagrant:~$ kubectl create -f production_deploy.yml -n production
> statefulset.apps/db-dpl created
> service/db-srv created
> deployment.apps/backend-dpl created
> service/backend-srv created
> deployment.apps/frontend-dpl created
> service/frontend-srv created
> ```
> 
> Проверим что получилось:    
>![13-01-02](2.png)

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).
 
> **Выполнение:**    
> 
> Направим существующий сервис на внешний эндтпоинт:    
> 
> ```console 
> vagrant@vagrant:~$ cat <<EOF | kubectl apply -f -
> ---
> apiVersion: v1
> kind: Endpoints
> metadata:
>   name: frontend-srv
>   namespace: production
> subsets: 
>   - addresses:
>       - ip: 213.180.193.58
>     ports:
>       - port: 80
>         name: web
> EOF
> ```
> 
> Проверяем что получилось:    
>![13-01-03](3.png)