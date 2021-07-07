Training playbook
=========
Downloads binaries from official websites and installs Java, Elasticsearch, Kibana, and Logstash (ELK) using the roles.

Inventory
--------------
* 192.168.17.140, Ubuntu 20.04 - control node
* 192.168.17.146, CentOS 8 - managed node, Java, Elasticsearch, Kibana
* 192.168.17.147, CentOS 8 - managed node, Java, Logstash

Parameters
--------------
Includes four plays and one environment `prod`.
The variables in the `vars` section are set to the versions of the installing applications.


Tags
--------------

Tag  | Descryption 
------------- | -------------
java	| Java install play
elastic | Elasticsearch install play
kibana | Kibana install play
logstash | Logstash install play
