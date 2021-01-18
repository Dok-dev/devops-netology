# Домашнее задание «2.4. Инструменты Git»

**1 - задание.**

  *`$ git log aefea -1 --pretty=format:'%H %s'`*

    aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md    
   
 Полный хеш: *aefead2207ef7e2aa5dc81a34aedf0cad4c32545*    
 Комментарий коммита: *Update CHANGELOG.md*


**2 - задание.**

  *`$ git log 85024d3 -1`*

    commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)    
    Author: tf-release-bot <terraform@hashicorp.com>    
    Date:   Thu Mar 5 20:56:10 2020 +0000    

    v0.12.23
   
 На этом коммите находится тег: *v0.12.23*    
 Комментарий коммита: *v0.12.23*


**3 - задание.**

  *`$ git log b8d720 --pretty=format:'%h %s' --graph -3`*

    *   b8d720f83 Merge pull request #23916 from hashicorp/cgriggs01-stable    
    |\    
    | * 9ea88f22f add/update community provider listings    
    |/    
    *   56cd7859e Merge pull request #23857 from hashicorp/cgriggs01-stable    
    |\    
 или    
  *`$ git show b8d720^@ --no-walk -s --pretty=format:'%H'`*

    56cd7859e05c36c06b56d013b55a252d0bb7e158
    9ea88f22fc6269854151c571162c5bcf958bee2b    
    
 Два родителя, с краткими хешами: *9ea88f22f* и *56cd7859e*    


**4 - задание.**

  *`$ git show v0.12.23..v0.12.24 -s --pretty=format:'%H %s'`*

    33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
    b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
    3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
    6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
    5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
    06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
    d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
    4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
    dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
    225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release


**5 - задание.**

  *`$ git log -S 'func providerSource(.*)' --pickaxe-regex --pretty=format:'%H %cd'`*

    5af1e6234ab6da412fb8637393c5a17a1b293663 Tue Apr 21 16:28:59 2020 -0700
    8c928e83589d90a031f811fae52a81be7153e82f Mon Apr 6 09:24:23 2020 -0700  

 Коммит 8c928e835 более ранний, соответственно впервые функция появилась в нем.
 
  

**6 - задание.**

  *`$ git log -S 'func globalPluginDirs(.*)' --pickaxe-regex --pretty=format:'%H'`* # список коммитов с добавлением/удалением функции   
  *`$ git show 8364383c359a6b738a436d1b7745ccdce178df47`* # смотрим в каком файле находится эта функция    
  *`$ git log -L :globalPluginDirs:plugins.go --pretty=format:'%H' -s`* # получаем коммиты где функция была изменена    

    78b12205587fe839f10d946ea3fdc06719decb05    
    52dbf94834cb970b510f2fba853a5b49ad9b1a46    
    41ab0aef7a0fe030e84018973a64135b11abcd70    
    66ebff90cdfaa6938f26f908c7ebad8d547fea17    
    8364383c359a6b738a436d1b7745ccdce178df47   


**7 - задание.**

  *`$ git log -S 'func synchronizedWriters(.*)' --pickaxe-regex --pretty=format:'%H %cd %an'`*
  
    bdfea50cc85161dea41be0fe3381fd98731ff786 Wed Dec 2 13:59:18 2020 -0500 James Bardin   
    5ac311e2a91e381e2f52234668b49ba670aa0fe5 Thu May 4 15:36:51 2017 -0700 Martin Atkins  
    
 Коммит 5ac311e2a был сделан раньше, значит автор функции Martin Atkins.
