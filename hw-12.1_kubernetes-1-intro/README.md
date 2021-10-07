# Домашнее задание к занятию "12.1 Компоненты Kubernetes"

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

### Как поставить на AWS:
- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
- установите миникуб и докер следующими командами:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  - chmod +x ./kubectl
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- проверить версию можно командой minikube version
- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
- после запуска стоит проверить статус: minikube status
- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system

### Для сброса кластера стоит удалить кластер и создать заново:
- minikube delete
- minikube start --vm-driver=none

Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0

Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)

**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.

> **Выполнение:**    
>
> ```console
> root@ip-172-31-21-11:~# minikube status
> minikube
> type: Control Plane
> host: Running
> kubelet: Running
> apiserver: Running
> kubeconfig: Configured
> 
> root@ip-172-31-21-11:~#  minikube delete
> * Uninstalling Kubernetes v1.22.2 using kubeadm ...
> * Deleting "minikube" in none ...
> * Removed all traces of the "minikube" cluster.
> 
> root@ip-172-31-21-11:~# minikube start --vm-driver=none
> * minikube v1.23.2 on Ubuntu 20.04 (xen/amd64)
> * Using the none driver based on user configuration
> ...
> * Starting control plane node minikube in cluster minikube
> ...
> * Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
> 
> root@ip-172-31-21-11:~# kubectl get pods --namespace=kube-system
> NAME                                      READY   STATUS    RESTARTS        AGE
> coredns-78fcd69978-z5bs2                  1/1     Running   0               115s
> etcd-ip-172-31-21-11                      1/1     Running   2               2m8s
> kube-apiserver-ip-172-31-21-11            1/1     Running   2               2m8s
> kube-controller-manager-ip-172-31-21-11   1/1     Running   5 (2m28s ago)   2m27s
> kube-proxy-l4stq                          1/1     Running   0               115s
> kube-scheduler-ip-172-31-21-11            1/1     Running   2               2m8s
> storage-provisioner                       1/1     Running   0               2m4s
>```

## Задача 2: Запуск Hello World
После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.

- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
- установить аддоны ingress и dashboard

> **Выполнение:**    
> 
> ```console
> ubuntu@ip-172-31-21-11:~$ mkdir minikube
> ubuntu@ip-172-31-21-11:~$ cd minikube
> ubuntu@ip-172-31-21-11:~/minikube$ vim server.js
> ubuntu@ip-172-31-21-11:~/minikube$ vim Dockerfile
> ubuntu@ip-172-31-21-11:~$ sudo docker build -t hello-world:latest -f Dockerfile .
> ubuntu@ip-172-31-21-11:~$ kubectl create deployment hello-node --image=hello-world
> ubuntu@ip-172-31-21-11:~/minikube$ sudo kubectl get deployments
> NAME         READY   UP-TO-DATE   AVAILABLE   AGE
> hello-node   1/1     1            1           45s
> ubuntu@ip-172-31-21-11:~/minikube$ sudo kubectl expose deployment hello-node --type=LoadBalancer --port=8080
> service/hello-node exposed
> ubuntu@ip-172-31-21-11:~/minikube$ sudo kubectl get services
> NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
> hello-node   LoadBalancer   10.99.125.173   <pending>     8080:31674/TCP   16s
> kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          13h
> ubuntu@ip-172-31-21-11:~/minikube$ sudo minikube service hello-node
> |-----------|------------|-------------|-----------------------------|
> | NAMESPACE |    NAME    | TARGET PORT |             URL             |
> |-----------|------------|-------------|-----------------------------|
> | default   | hello-node |        8080 |   http://172.31.21.11:31674 |
> |-----------|------------|-------------|-----------------------------|
> * Opening service default/hello-node in default browser...
> http://172.31.21.11:31674
> ubuntu@ip-172-31-21-11:~/minikube$ curl http://127.0.0.1:31674
> Hello World!
> 
> ubuntu@ip-172-31-21-11:~$ sudo minikube addons enable ingress
> ubuntu@ip-172-31-21-11:~$ sudo minikube addons enable metrics-server
> ubuntu@ip-172-31-21-11:~$ sudo minikube addons enable dashboard
> ubuntu@ip-172-31-21-11:~$ sudo minikube addons list
> |-----------------------------|----------|--------------|-----------------------|
> |         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
> |-----------------------------|----------|--------------|-----------------------|
> | ambassador                  | minikube | disabled     | unknown (third-party) |
> | auto-pause                  | minikube | disabled     | google                |
> | csi-hostpath-driver         | minikube | disabled     | kubernetes            |
> | dashboard                   | minikube | enabled ✅   | kubernetes            |
> | default-storageclass        | minikube | enabled ✅   | kubernetes            |
> | efk                         | minikube | disabled     | unknown (third-party) |
> | freshpod                    | minikube | disabled     | google                |
> | gcp-auth                    | minikube | disabled     | google                |
> | gvisor                      | minikube | disabled     | google                |
> | helm-tiller                 | minikube | disabled     | unknown (third-party) |
> | ingress                     | minikube | disabled     | unknown (third-party) |
> | ingress-dns                 | minikube | disabled     | unknown (third-party) |
> | istio                       | minikube | disabled     | unknown (third-party) |
> | istio-provisioner           | minikube | disabled     | unknown (third-party) |
> | kubevirt                    | minikube | disabled     | unknown (third-party) |
> | logviewer                   | minikube | disabled     | google                |
> | metallb                     | minikube | disabled     | unknown (third-party) |
> | metrics-server              | minikube | enabled ✅   | kubernetes            |
> | nvidia-driver-installer     | minikube | disabled     | google                |
> | nvidia-gpu-device-plugin    | minikube | disabled     | unknown (third-party) |
> | olm                         | minikube | disabled     | unknown (third-party) |
> | pod-security-policy         | minikube | disabled     | unknown (third-party) |
> | portainer                   | minikube | disabled     | portainer.io          |
> | registry                    | minikube | disabled     | google                |
> | registry-aliases            | minikube | disabled     | unknown (third-party) |
> | registry-creds              | minikube | disabled     | unknown (third-party) |
> | storage-provisioner         | minikube | enabled ✅   | kubernetes            |
> | storage-provisioner-gluster | minikube | disabled     | unknown (third-party) |
> | volumesnapshots             | minikube | disabled     | kubernetes            |
> |-----------------------------|----------|--------------|-----------------------|
>```

## Задача 3: Установить kubectl

Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
- подключиться к minikube 

> **Выполнение:**   
> ```console
> # Установка клиента
> vagrant@vagrant:~$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
>                                  Dload  Upload   Total   Spent    Left  Speed
> 100 44.7M  100 44.7M    0     0  6827k      0  0:00:06  0:00:06 --:--:-- 6918k
> vagrant@vagrant:~$ chmod +x ./kubectl
> vagrant@vagrant:~$ sudo mv ./kubectl /usr/local/bin/kubectl
> vagrant@vagrant:~$ kubectl version --client
> Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.2", GitCommit:"8b5a19147530eaac9476b0ab82980b4088bbc1b2", GitTreeState:"clean", BuildDate:"2021-09-15T21:38:50Z", GoVersion:"go1.16.8", Compiler:"gc", Platform:"linux/amd64"}
> 
> # Для подключения на понадобится файл конфигурации, пользователь и ключи, все берем отсюда:
> root@ip-172-31-21-11:~/.kube# cat config
> apiVersion: v1
> clusters:
> - cluster:
>     certificate-authority: /root/.minikube/ca.crt
>     extensions:
>     - extension:
>         last-update: Tue, 05 Oct 2021 07:17:40 UTC
>         provider: minikube.sigs.k8s.io
>         version: v1.23.2
>       name: cluster_info
>     server: https://172.31.21.11:8443
>   name: minikube
> contexts:
> - context:
>     cluster: minikube
>     extensions:
>     - extension:
>         last-update: Tue, 05 Oct 2021 07:17:40 UTC
>         provider: minikube.sigs.k8s.io
>         version: v1.23.2
>       name: context_info
>     namespace: default
>     user: minikube
>   name: minikube
> current-context: minikube
> kind: Config
> preferences: {}
> users:
> - name: minikube
>   user:
>     client-certificate: /root/.minikube/profiles/minikube/client.crt
>     client-key: /root/.minikube/profiles/minikube/client.key
> ```

- проверить работу приложения из задания 2, запустив port-forward до кластера

> **Выполнение:**    
> ```console
> vagrant@vagrant:~$ curl http://18.184.59.79:31674
> vagrant@vagrant:~$ Hello World!
>```
## Задача 4 (*): собрать через ansible (необязательное)

Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
 - собрать роль для установки minikube на aws сервисе (с установкой ingress)
 - собрать роль для запуска в кластере hello world
  
> **Выполнение:**    
> ```console
> vagrant@vagrant:~$ sudo apt install ansible    
> vagrant@vagrant:~$ sudo ansible-galaxy collection install kubernetes.core    
> vagrant@vagrant:~$ ansible-galaxy collection install amazon.aws    
> vagrant@vagrant:~$ sudo pip3 install boto3
>```
> **Ответ:**  
> Playbook для сборки кластера: https://github.com/Dok-dev/devops-netology/tree/main/hw-12.1_kubernetes-1-intro/playbook    
> Роли для Playbook: https://github.com/Dok-dev/devops-netology/tree/main/hw-12.1_kubernetes-1-intro/roles    
> Вторая роль для "hello world"- только набросок и не доведена до ума, на текущий момент 4е задание отняло у меня слишком много времени и задерживает выполнение дальнейших заданий. Пока ограничил на этом работу.