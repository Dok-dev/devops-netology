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
