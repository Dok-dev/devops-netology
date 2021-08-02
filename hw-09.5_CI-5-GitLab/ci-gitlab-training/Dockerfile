FROM centos:7

RUN yum update -y && yum install -y python3 python3-pip
RUN pip3 install flask flask-jsonpify flask_restful

ADD python-api.py /python_api/

EXPOSE 5290 5290

CMD ["/python_api/python-api.py"]
ENTRYPOINT ["python3"]
