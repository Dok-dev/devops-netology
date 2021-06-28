#!/bin/sh

docker build -t 0dok0/ubuntu -f DockerFile .

docker run -d --name centos7 centos:7 sleep 172800
docker run -d --name ubuntu 0dok0/ubuntu sleep 172800
docker run -d --name fedora1 pycontribs/fedora sleep 172800

sudo ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass

docker stop centos7 ubuntu fedora1
