# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

> **Выполнение:**    
> 
> Подготовим файл для деплоймента двух подов с монтированием общей папки:    
> ```console   
> vagrant@vagrant:~$ vim stage_deploy.yml
> ```
> ```yaml
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
>         volumeMounts:
>         - mountPath: /static
>           name: static-vl
>       - name: backend
>         image: 0dok0/kubernetes-config_frontend
>         ports:
>         - containerPort: 9000
>         volumeMounts:
>         - mountPath: /static
>           name: static-vl
>
>       volumes:
>       - name: static-vl
>         emptyDir: {}
> ```
>
> Разместим deployment:
> ```console 
> vagrant@vagrant:~$ kubectl create -f stage_deploy.yml -n stage
> deployment.apps/frontend-backend-dpl created
> statefulset.apps/db-dpl created
> ```
> Проверяем что получилось:    
> ![13-02-01](1.png)

## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.
 
> **Выполнение:**    
> 
> Устанавливаем helm и nfs-server (как указано в шапке) на первой ноде и пакет nfs-common на всех:
> 
> Проверяем состояние Storage Classes:    
> ![13-02-02](2.png)
>
> Небходимый storage сlass ужу создался, поэтому переходим сразу к созданию связи-PVC для подов:
> ```console 
> cat <<EOF | kubectl create -f -
> ---
> apiVersion: v1
> kind: PersistentVolumeClaim
> metadata:
>   name: pvc-front-back
>   namespace: production
> spec:
>   storageClassName: nfs
>   accessModes:
>     - ReadWriteMany
>   resources:
>     requests:
>       storage: 1Gi
> EOF
> ```
> 
> Проверяем что получилось:    
> ![13-02-03](3.png)
>
> Создадим поды с запросом необходимого типа тома:
> ```console   
> vagrant@vagrant:~$ vim production_deploy.yml
> ```
> ```yaml
> ---
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: backend-dpl
>   namespace: production
>   labels:
>     app: backend
> spec:
>   replicas: 1
>   selector:
>     matchLabels:
>       app: backend
>   template:
>     metadata:
>       labels:
>         app: backend
>     spec:
>       containers:
>       - name: backend
>         image: 0dok0/kubernetes-config_backend
>         ports:
>         - containerPort: 9000
>         env:
>           - name: DATABASE_URL
>             value: postgres://postgres:postgres@db-srv:5432/news
>         volumeMounts:
>           - mountPath: "/dynamic"
>             name: pvc-front-back-volume
>       volumes:
>        - name: pvc-front-back-volume
>          persistentVolumeClaim:
>            claimName: pvc-front-back
> ---
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: frontend-dpl
>   namespace: production
>   labels:
>     app: frontend
> spec:
>   replicas: 1
>   selector:
>     matchLabels:
>       app: frontend
>   template:
>     metadata:
>       labels:
>         app: frontend
>     spec:
>       containers:
>       - name: frontend
>         image: 0dok0/kubernetes-config_frontend
>         ports:
>         - containerPort: 80
>         env:
>           - name: BASE_URL
>             value: http://backend:9000
>         volumeMounts:
>           - mountPath: "/dynamic"
>             name: pvc-front-back-volume
>       volumes:
>        - name: pvc-front-back-volume
>          persistentVolumeClaim:
>            claimName: pvc-front-back
> ```
> 
> Удаляем прошлый деплоймент и создаем новый, хотя наверное можно было сделать apply поверх:
> ```console 
> vagrant@vagrant:~$ kubectl delete deployments.apps backend-dpl frontend-dpl -n production
> deployment.apps "backend-dpl" deleted
> deployment.apps "frontend-dpl" deleted
> vagrant@vagrant:~$ kubectl create -f production_deploy.yml -n production
> deployment.apps/backend-dpl created
> deployment.apps/frontend-dpl created
> ```
> Проверим как создался том:    
> ![13-02-04](4.png)
>
> Проверим его работу:    
> ![13-02-05](5.png)