# Домашнее задание «7.2. Облачные провайдеры и синтаксис Терраформ.»

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services).

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services).

## Задача 1. Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первых год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

>**Выполнение:**    
```
# Установка aws-cli:
sudo apt-get install pip
sudo pip install awscli

# Настроим авторизацию сперва под рутовым пользователем
aws configure

# Создаем нового пользователя terraform и помещаем в группу Admins
aws iam create-user --user-name terraform
aws iam create-access-key --user-name terraform
aws iam create-group --group-name Admins
aws iam add-user-to-group --user-name terraform --group-name Admins

# Выдача прав на группу согласно заданию:
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name Admins
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name Admins
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --group-name Admins
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess --group-name Admins
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess --group-name Admins
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name Admins

echo export AWS_ACCESS_KEY_ID=(terraform access key id) >> ~/.bashrc
echo export AWS_SECRET_ACCESS_KEY=(terraform secret access key) >> ~/.bashrc

# Перенастроим авторизацию консоли под пользователя terraform
aws configure
```
>**Ответ:**    
```
vagrant@vagrant:~$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************WAIK              env
secret_key     ****************3rqG              env
    region                us-west-2      config-file    ~/.aws/config
```
---

## Задача 2. Созданием ec2 через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
1. Зарегистрируйте провайдер для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
внутри блока `provider`.
1. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунта. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
1. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
1. В файле `main.tf` создайте рессурс [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
`Example Usage`, но желательно, указать большее количество параметров. 
1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
1. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
    * AWS account ID,
    * AWS user ID,
    * AWS регион, который используется в данный момент, 
    * Приватный IP ec2 инстансы,
    * Идентификатор подсети в которой создан инстанс.  
1. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 

>**Выполнение:**    
```
vagrant@vagrant:~/terraform$ terraform init

vagrant@vagrant:~/terraform$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.netology-ec2 will be created
  + resource "aws_instance" "netology-ec2" {
      + ami                                  = "ami-038a0ccaaedae6406"
                     ...
Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + account_id = "654371877596"
  + private_ip = [
      + (known after apply),
    ]
  + public_ip  = [
      + (known after apply),
    ]
  + region     = "us-west-2"
  + subnet_id  = [
      + (known after apply),
    ]
  + user_id    = "************WAIK"
```
В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?    
>**Ответ:**    
>Образ ami можно создать при помощи Packer. Кроме него есть еще ряд способов создать образ. Например, есть возможность создания пользовательского образа в web-интерфейсе AWS.

1. Ссылку на репозиторий с исходной конфигурацией терраформа.  

>**Ответ:**    
https://github.com/Dok-dev/devops-netology/tree/main/terraform