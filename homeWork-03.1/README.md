# Домашнее задание «3.1. Работа в терминале, лекция 1»

**1..4 - задание.**

![1..4](hw-03.1.1-4.jpg)


**5 - задание.**

![5](hw-03.1.5.jpg)
![5_2](hw-03.1.5_2.jpg)
  
  
**6 - задание.**

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
   config.vm.provider "virtualbox" do |vub|
     vub.memory = 2048
     vub.cpus = 2
   end
end 
```


**7 - задание.**    

![7](hw-03.1.7.jpg)


**8 - задание.**

Переменна HISTSIZE задает длину журнала history.

```bash
 man bash | grep -n -A2 'HISTSIZE'
```
или
```bash
 man bash
  -N
  &HISTSIZE
```

```text
HISTSIZE
              The number of commands to remember in the command history (see HISTORY below).  If the value is 0, commands are not saved in the history list.  Numeric values less than zero result in every command being saved on the history list (there is no limit).  The shell sets the default value to 500 after reading any startup files.
```
Строка 517 (при моем размее окна).


Директива `ignoreboth` это объединение параметров `ignoredups` и `ignorespace`, отвечающих за отключение записи дубликатов строк в историю и отключение записи строк начанающихся с пробела.


**9 - задание.**

{} - вариант списка выполняемого в среде текущего командного интерпретатора.    
Сторока man bash 173 (при моем размее окна):    
```text
 { list; }
              list is simply executed in the current shell environment.  list must be terminated with a newline or semicolon.  This is known as a group command.  The return status is the exit status of list.  Note that unlike the metacharacters ( and ), { and } are reserved words and must occur where a reserved word  is  permitted  to  be  recognized.
              Since they do not cause a word break, they must be separated from list by whitespace or another shell metacharacter.
```


**10 - задание.**
```bash
touch {1..100000}
```

```bash
touch {1..300000}
-bash: /usr/bin/touch: Argument list too long
```
Превышает максимальную длину аргументов среды. Столько файлов нельзя создать одной коммандой.    
```bash
getconf ARG_MAX
2097152
```


**11 - задание.**

Конструкция `[[ -d /tmp ]]` проверяет существование каталога, вернет ноль если файл существует и является каталогом.


**12 - задание.**

```bash
mkdir /tmp/new_path_directory
cp /bin/bash /tmp/new_path_directory/bash
PATH=/tmp/new_path_directory:$PATH

type -a bash
bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
```


**13 - задание.**

Комманды `batch` и `at` являются частью пакета at используемого для выполнения разовых задач.    
`at` - добавляет разовое задание в оределенное время. Например : `at -f test.sh 22:30` или `at -f test.sh now + 10 hours`.    
`batch` - добавляет разовое задание, которое выполнится во время периода низкой загруженности системы. Другими словами, когда средний уровень загрузки системы падает ниже значения 1.5 или того значения, которое задано при вызове atd.


**14 - задание.**

`vagrant halt` см. скрин задания 1..4.
