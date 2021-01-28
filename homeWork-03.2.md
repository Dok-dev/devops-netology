# Домашнее задание «3.2. Работа в терминале, лекция 2»

**1 - задание.**

```bash
:~$ type cd
cd is a shell builtin
```
Команда `cd` - встроенная команда оболочки Bash. Потому, что это основная навигационная команда и было бы странно, если она являлась, к примеру, утилитой.


**2 - задание.**

```bash
grep -c <some_string> <some_file>
```
  
**3 - задание.**

```bash
:~$ pstree -p
systemd(1)─┬─VBoxService(806)─┬─{VBoxService}(807)
```
systemd


**4 - задание.**    

```bash
:~$ who
vagrant  pts/0        2021-01-26 16:00 (192.168.2.2)
vagrant  pts/1        2021-01-27 12:00 (192.168.2.3)
:~$ ls ? 2>/dev/pts/1
:~$ 
```


**5 - задание.**

```bash
:~$ cat < 1.txt > 2.txt
```


**6 - задание.**

```bash
:~$ who
vagrant  tty1         2021-01-27 13:47
vagrant  pts/0        2021-01-26 16:00 (192.168.2.2)
:~$ echo Hello >/dev/tty1
:~$ 
```
Данные передаваемые с pts/0 успешно выводятся в окне терминала tty1.


**7 - задание.**

`bash 5>&1` - приведет к запуску нового интерпритатора Bash c 5 номером потока (дескриптором) вода/вывода, что видно при выполнении:
```bash
:~$ ls -la /proc/$$/fd
total 0
dr-x------ 2 vagrant vagrant  0 Jan 27 14:01 .
dr-xr-xr-x 9 vagrant vagrant  0 Jan 27 14:01 ..
lrwx------ 1 vagrant vagrant 64 Jan 27 14:01 0 -> /dev/pts/0
lrwx------ 1 vagrant vagrant 64 Jan 27 14:01 1 -> /dev/pts/0
lrwx------ 1 vagrant vagrant 64 Jan 27 14:01 2 -> /dev/pts/0
lrwx------ 1 vagrant vagrant 64 Jan 27 14:01 255 -> /dev/pts/0
lrwx------ 1 vagrant vagrant 64 Jan 27 14:01 5 -> /dev/pts/0
```
И перенаправлению вывода этого потока в stdout (поток 1). Что нам и илюстрирует комманда `echo netology > /proc/$$/fd/5`
Которая передает в файл 5го потока вывод комманды `echo netology`.


**8 - задание.**

```bash
:~$ ls                                                   # листинг для понимания
    000  '[1]'   5   nohup.out   screenlog.0   test.sh   wget-log   wget-log.1
:~$ ls zzz 3>&1 2>&1 | grep 'No'
    ls: cannot access 'zzz': No such file or directory   # stderr успешно передался в на pipe
:~$ ls *.* 3>&1 2>&1 | grep 'test'
    test.sh                                              # stdout тоже поступает на pipe
```


**9 - задание.**

`cat /proc/$$/environ` - выведет файл со списоком переменных окружения для текущего процесса Bash. Аналогичный вывод можно получить коммандой `env`


**10 - задание.**
```text
       /proc/[pid]/exe
              Under Linux 2.2 and later, this file is a symbolic link containing the actual pathname of the executed command.  This symbolic link can be dereferenced normally; attempting to open it will open the executable.  You can even type /proc/[pid]/exe to run another copy of the same executable that is
              being run by process [pid].  If the pathname has been unlinked, the symbolic link will contain the string '(deleted)' appended to the original pathname.  In a multithreaded process, the contents of this symbolic link are not available if the main thread  has  already  terminated  (typically  by
              calling pthread_exit(3)).
			  
       /proc/[pid]/cmdline
              This  read-only  file holds the complete command line for the process, unless the process is a zombie.  In the latter case, there is nothing in this file: that is, a read on this file will return 0 characters.  The command-line arguments appear in this file as a set of strings separated by null
              bytes ('\0'), with a further null byte after the last string.
```
`/proc/<PID>/cmdline` - содержит полную коммандную строку к выполняемому процессу.    
`/proc/<PID>/exe` - содержит сомволическую ссылку на актуальный путь выполняемого процесса.    


**11 - задание.**

```bash
:~$ cat /proc/cpuinfo | grep sse
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt aes xsave avx rdrand hypervisor lahf_lm pti fsgsbase
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt aes xsave avx rdrand hypervisor lahf_lm pti fsgsbase
```
sse4_2


**12 - задание.**

SSH по умолчанию не выделяет TTY, когда команда передается как аргумент при подключении (в отличие от запуска полной версии интерактивной оболочки).

```bash
:~$ ssh -o "requestTTY=yes" localhost 'tty' # или  ssh -t localhost 'tty'
    @localhost's password:
    /dev/pts/1
```


**13 - задание.**

```bash
:~$ ./test.sh # цикл ls + sleep
    000  5  nohup.out  screenlog.0  test.sh  wget-log  wget-log.1
^Z
    [1]+  Stopped                 ./test.sh
:~$ disown -a
    -bash: warning: deleting stopped job 1 with process group 1046
:~$ sudo screen -R test                                        #почему reptyr то работает только под рутом
 :~$ ps -ax | grep test.sh
     1046 pts/2    T      0:00 /bin/bash ./test.sh
 :~$reptyr -T 1046  
```


**14 - задание.**

Команда `tee` принимает данные из одного источника и может сохранять их на выходе в нескольких местах.
Конструкция `echo string | sudo tee /root/new_file` будет работать т.к. в данном случае stdout передается в stdin команде выполняемой с правами root.
