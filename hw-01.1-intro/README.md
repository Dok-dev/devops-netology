# Домашнее задание к занятию «1.1. Введение в DevOps»

## Задание №1 - Подготовка рабочей среды

Вы пришли на новое место работы или приобрели новый компьютер.
Первым делом надо настроить окружение для дальнейшей работы. 

1. Установить Py Charm Community Edition: https://www.jetbrains.com/ru-ru/pycharm/download/ - это бесплатная версия IDE. 
Если у вас уже установлен любой другой продукт от JetBrains,то можно использовать его. 
1. Установить плагины:
    - Terraform,
    - MarkDown,
    - Yaml/Ansible Support,
    - Jsonnet.
1. Склонировать текущий репозиторий или просто создать файлы для проверки плагинов:
    - [netology.tf](netology.tf) – терраформ,
    - [netology.sh](netology.sh) – bash,
    - [netology.md](netology.md) – markdown, 
    - [netology.yaml](netology.yaml) – yaml,
    - [netology.jsonnet](netology.jsonnet) – jsonnet.
1. Убедитесь, что работает подсветка синтаксиса, файлы должны выглядеть вот так:
    - Terraform: ![Терраформ](img/terraform.png)
    - Bash: ![bahs](img/bash.png)
    - Markdown: ![markdown](img/markdown.png)
    - Yaml: ![Yaml](img/yaml.png)
    - Jsonnet: ![Jsonnet](img/jsonnet.png)
1. Добавьте свое имя в каждый файл, сделайте снимок экран и загрузите его на любой сервис обмена картинками.

> **Выполнение:**
>
> ![Terraform](Terraform.png)    
> ![bash](bash.png)    
> ![Markdown](Markdown.png)    
> ![Yaml](Yaml.png)    
> ![Jsonnet](Jsonnet.png)    


## Задание №2 - Описание жизненного цикла задачи (разработки нового функционала)

Чтобы лучше понимать предназначение дальнейших инструментов, с которыми нам предстоит работать, давайте 
составим схему жизненного цикла задачи в идеальном для вас случае.

### Описание истории

Представьте, что вы работаете в стартапе, который запустил интернет-магазин. Ваш интернет-магазин достаточно успешно развивался, и вот пришло время налаживать процессы: у вас стало больше конечных клиентов, менеджеров и разработчиков.Сейчас от клиентов вам приходят задачи, связанные с разработкой нового функционала. Задач много, и все они требуют выкладки на тестовые среды, одобрения тестировщика, проверки менеджером перед показом клиенту. В случае необходимости, вам будет необходим откат изменений. 

### Решение задачи

Вам необходимо описать процесс решения задачи в соответствии с жизненным циклом разработки программного обеспечения. Использование какого-либо конкретного метода разработки не обязательно. Для решения главное - прописать по пунктам шаги решения задачи (релизации в конечный результат) с участием менеджера, разработчика (или команды разработчиков), тестировщика (или команды тестировщиков) и себя как DevOps-инженера. 

> **Выполнение:**
> 1. Переговоры с заказчиком и формулировка задач. (Менеджер, системный архитектор)
> 2. Проектирование, подготовка технических задач, выбор инструментов. (системный архитектор, старший разработчик, инженер-DevOps)
> 3. Внешняя интеграция. Лицензирование, соглашения о взаимодействии и т.п. (менеджер, ?, инженер-DevOps)
> 4. Написание кода и конфигов, подготовка тестовой среды. Написание документации. (разработчики, инженер-DevOps)
> 5. Внутреннее тестирование на тестовой среде. (тестировщики, менеджер, инженер-DevOps)
> 6. Доработка по результатам внутреннего тестирования. (разработчики, инженер-DevOps)
> 7. Демонстрация заказчику. (менеджер)
> 8. Доработка, если требуется, по результатам согласования с заказчиком. Внутреннее тестирование.
> 9. Согласование с заказчиком, выкладка результата в продакшен. (менеджер, инженер-DevOps)
> 10. Если прописано в контракте - получение фидбэка, мониторинг, дальнейшая доработка и тестирование. (менеджер, инженер-DevOps)

---

Андрей Борю (преподаватель)
12 декабря 2020 06:24

Здравствуйте, Тимофей!

Спасибо за выполненную работу.
С плагинами все верно. Описание хорошее, дальше в курсе мы будем разбирать все эти шаги более подробно.
До встречи на занятиях.