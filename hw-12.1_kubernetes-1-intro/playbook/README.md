Training playbook
=========
Install minikube to AWS with ingress adddon and hello-world role.

Inventory
--------------
* localhost, Ubuntu 20.04 - control node
* AWS ec2, Ubuntu 20.04 - master node

Parameters
--------------
Includes four plays and one environment `prod`.
The variables in the `vars` section are set to the versions of the installing applications.


Tags
--------------

Tag  | Descryption 
------------- | -------------
minikube	| Minikube install play
hello-world | Hello World install play
