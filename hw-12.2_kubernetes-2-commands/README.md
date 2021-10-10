# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"

Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods
 
> **Выполнение:**    
> ```console
> ubuntu@ip-172-31-21-11:~$ sudo kubectl create deployment hello-node --image=hello-world --replicas=2
> deployment.apps/hello-node created
> ubuntu@ip-172-31-21-11:~$ kubectl get deployment
> NAME         READY   UP-TO-DATE   AVAILABLE   AGE
> hello-node   2/2     2            2           8s
> ubuntu@ip-172-31-21-11:~$ kubectl get pods
> NAME                          READY   STATUS    RESTARTS   AGE
> hello-node-7567d9fdc9-4dfqd   1/1     Running   0          15s
> hello-node-7567d9fdc9-t2hlz   1/1     Running   0          15s
>```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

> **Выполнение:**    
> По умолчанию в кластере используются две схемы авторизации - Service Account tokens и сертификаты X509.
> Сделаем авторизацию на сертификатах X509.
> 
> Создадим пользователя vasia и его закрытый ключ RSA:
> ```console
> root@ip-172-31-21-11:/# sudo useradd -m vasia
> root@ip-172-31-21-11:/# cd /home/vasia
> root@ip-172-31-21-11:/home/vasia# openssl genrsa -out vasia.key 2048
> Generating RSA private key, 2048 bit long modulus (2 primes)
> .+++++
> ......................................+++++
> e is 65537 (0x010001)
> root@ip-172-31-21-11:/home/vasia# ls
> vasia.key
>```
>
> Формируем файл запроса подписи ключа c добавлением vasia в группу readers:
> ```console
> root@ip-172-31-21-11:/home/vasia# openssl req -new -key vasia.key -out vasia.csr -subj "/CN=vasia/O=readers"
> root@ip-172-31-21-11:/home/vasia# ls
> vasia.csr  vasia.key
>```
>
> Создадим ресурс Kubernetes Certificate Signing Request в файле csr.yaml:
> ```console
> root@ip-172-31-21-11:/home/vasia# vim csr.yaml
> apiVersion: certificates.k8s.io/v1
> kind: CertificateSigningRequest
> metadata:
>  name: vasia
> spec:
>  request: ${BASE64_CSR}
>  signerName: kubernetes.io/kube-apiserver-client
>  expirationSeconds: 8640000  # 100 days
>  usages:
>    - digital signature
>    - key encipherment
>#   - server auth
>    - client auth
>```
>
> Кодируем в base64 файл .csr:
> ```console
> root@ip-172-31-21-11:/home/vasia# export BASE64_CSR=$(cat ./vasia.csr | base64 | tr -d '\n')
>```
>
> Подставляем переменную env BASE64_CSR и создаем ресурс CertificateSigninRequest:
> ```console
> root@ip-172-31-21-11:/home/vasia# cat csr.yaml | envsubst | kubectl apply -f -
> certificatesigningrequest.certificates.k8s.io/vasia created
>```
>
> Проверим статус созданного CSR запроса:
> ```console
> root@ip-172-31-21-11:/home/vasia# kubectl get csr
> 
> NAME    AGE   SIGNERNAME                            REQUESTOR       REQUESTEDDURATION   CONDITION
> csr-csdlr   55m    kubernetes.io/kube-apiserver-client-kubelet   system:node:ip-172-31-21-11   <none>              Approved,Issued
> vasia   5m    kubernetes.io/kube-apiserver-client   minikube-user   100d                Pending
>```
>
> Подтверждаем запрос:
> ```console
> root@ip-172-31-21-11:/home/vasia# kubectl certificate approve vasia
> certificatesigningrequest.certificates.k8s.io/vasia approved
> root@ip-172-31-21-11:/home/vasia# kubectl get csr
> NAME    AGE   SIGNERNAME                            REQUESTOR       REQUESTEDDURATION   CONDITION
> csr-csdlr   57m    kubernetes.io/kube-apiserver-client-kubelet   system:node:ip-172-31-21-11   <none>              Approved,Issued
> vasia       7m   kubernetes.io/kube-apiserver-client           minikube-user                 100d                Approved,Issued
>```
>
> Сертификат подписан, теперь извлечем его из ресурса CSR, сохраним в файле с именем vasia.crt:
> ```console
> root@ip-172-31-21-11:/home/vasia# kubectl get csr vasia -o jsonpath='{.status.certificate}' | base64 --decode > vasia.crt
>```
>
> Посмотрим что внутри:
> ```console
> root@ip-172-31-21-11:/home/vasia# openssl x509 -in ./vasia.crt -noout -text
> Certificate:
>     Data:
>         Version: 3 (0x2)
>         Serial Number:
>             ec:36:49:0a:6f:14:eb:aa:e2:47:46:20:3c:31:c4:09
>         Signature Algorithm: sha256WithRSAEncryption
>         Issuer: CN = minikubeCA
>         Validity
>             Not Before: Oct 10 13:54:59 2021 GMT
>             Not After : Jan 18 13:54:59 2022 GMT
>         Subject: O = readers, CN = vasia
>         Subject Public Key Info:
>             Public Key Algorithm: rsaEncryption
>                 RSA Public-Key: (2048 bit)
>                 Modulus:
> ...
>                 Exponent: 65537 (0x10001)
>         X509v3 extensions:
>             X509v3 Key Usage: critical
>                 Digital Signature, Key Encipherment
>             X509v3 Extended Key Usage:
>                 TLS Web Client Authentication
>             X509v3 Basic Constraints: critical
>                 CA:FALSE
>             X509v3 Authority Key Identifier:
>                 keyid:3D:32:9C:06:2A:07:3A:17:8E:EA:11:CA:73:22:6B:F9:AE:52:26:C1
> 
>     Signature Algorithm: sha256WithRSAEncryption
> ...
>```
>
> Переместим сертификаты в каталог .certs у vasia:
> ```console
> root@ip-172-31-21-11:/home/vasia# mkdir .certs && mv vasia.crt vasia.key .certs
>```
>
> Создадим пользователя внутри Kubernetes:
> ```console
> root@ip-172-31-21-11:/home/vasia# kubectl config set-credentials vasia --client-certificate=/home/vasia/.certs/vasia.crt --client-key=/home/vasia/.certs/vasia.key
> User "vasia" set.
>```
>
> Задаем контекст пользователя:
> ```console
> root@ip-172-31-21-11:/home/vasia# kubectl config set-context vasia-context --cluster=minikube --user=vasia
> User "vasia" set.
>```
>
> Создадим файл конфигурации пользователя на основе файла конфигурации кластера:
> ```console
> root@ip-172-31-21-11:/home/vasia# cp /root/.minikube/ca.crt /etc/kubernetes/pki/ca.crt # из за особенностей minikube сертификат кластера придется переложить
> root@ip-172-31-21-11:/home/vasia# mkdir .kube && vim config
> apiVersion: v1
> clusters:
> - cluster:
>     certificate-authority: /etc/kubernetes/pki/ca.crt
>     server: https://172.31.21.11:8443
>   name: minikube
> contexts:
> - context:
>     cluster: minikube
>     namespace: app-namespace
>     user: vasia
>   name: vasia-context
> current-context: vasia-context
> kind: Config
> preferences: {}
> users:
> - name: vasia
>   user:
>     client-certificate: /home/vasia/.certs/vasia.crt
>     client-key: /home/vasia/.certs/vasia.key
>```
>
> Сделаем пользователю права на подготовленные файлы:
> ```console
> root@ip-172-31-21-11:/home/vasia# chown -R vasia:vasia /home/vasia
>```
>
> Создадим пространство имен app-namespace в котором по плану будет работать vasia:
> ```console
> root@ip-172-31-21-11:/# kubectl create ns app-namespace
> namespace/app-namespace created
>```
>
> Теперь необходимо создать роль согласно которой пользователю будут предоставляться права:
> ```console
> root@ip-172-31-21-11:/tmp# vim rolefile.yml
> apiVersion: rbac.authorization.k8s.io/v1
> kind: Role
> metadata:
>   namespace: app-namespace
>   name: readers
> rules:
> - apiGroups: [""]
>   resources: ["pods"]
>   verbs: ["get", "list", "describe", "logs"]
> - apiGroups: ["apps"]
>   resources: ["pods"]
>   verbs: ["get", "list", "describe", "logs"]
>
> root@ip-172-31-21-11:/tmp# kubectl create -f rolefile.yml
> role.rbac.authorization.k8s.io/readers created
>```
>
> Применяем эту роль на пользователя:
> ```console
> root@ip-172-31-21-11:/tmp# vim roleapply.yml
> apiVersion: rbac.authorization.k8s.io/v1
> kind: RoleBinding
> metadata:
>   name: pod-reader
>   namespace: app-namespace
> subjects:
> - kind: User
>   name: vasia
>   apiGroup: rbac.authorization.k8s.io
> roleRef:
>   kind: Role
>   name: readers
>   apiGroup: rbac.authorization.k8s.io
>
> root@ip-172-31-21-11:/tmp# kubectl apply -f roleapply.yml
> role.rbac.authorization.k8s.io/readers created
>```
>
> Проверяем что получилось:
> ```console
> root@ip-172-31-21-11:/# kubectl auth can-i list pods --as vasia
> yes
> root@ip-172-31-21-11:/tmp# su - vasia
> $ kubectl get pods -n app-namespace
> No resources found in app-namespace namespace.
>```
> Что и следовало ожитать т.к. ресурсы создавались в дефлтном namespace. Разворачиваем deployment в нужном namespace:
> ```console
> root@ip-172-31-21-11:/tmp# kubectl delete deployment hello-node
> deployment.apps "hello-node" deleted
> root@ip-172-31-21-11:/tmp# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2 -n app-namespace
> deployment.apps/hello-node created
> root@ip-172-31-21-11:/tmp# su - vasia
> $ kubectl get pods
> NAME                          READY   STATUS    RESTARTS   AGE
> hello-node-7567d9fdc9-2cc6x   1/1     Running   0          14s
> hello-node-7567d9fdc9-qmppm   1/1     Running   0          14s
>```

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)
  
> **Выполнение:**    
> ```console
> root@ip-172-31-21-11:/# kubectl scale --replicas=5 deployment/hello-node -n app-namespace
> deployment.apps/hello-node scaled
> root@ip-172-31-21-11:/# kubectl get pods -n app-namespace
> NAME                          READY   STATUS    RESTARTS   AGE
> hello-node-7567d9fdc9-2cc6x   1/1     Running   0          10m
> hello-node-7567d9fdc9-qmppm   1/1     Running   0          10m
> hello-node-7567d9fdc9-wrsrn   1/1     Running   0          37s
> hello-node-7567d9fdc9-wtbm5   1/1     Running   0          37s
> hello-node-7567d9fdc9-x2wg6   1/1     Running   0          37s
>```

---

#### Использованные источники:
https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/    
https://habr.com/ru/company/flant/blog/468679/    
https://mcs.mail.ru/blog/kak-predostavit-dostup-k-kubernetes    
https://habr.com/ru/company/flant/blog/470503/    