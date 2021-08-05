FROM centos:7

RUN yum update -y && \
  yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel make

ADD python-api.py /python_api/  

ADD https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz /

RUN tar -xzf Python-3.9.6.tgz \
  && rm Python-3.9.6.tgz \
  && cd Python-3.9.6 && ./configure --enable-optimizations \
  && make altinstall

RUN yum install -y epel-release \
  && curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py \
  && python3.9 get-pip.py

RUN pip3 install flask flask-jsonpify flask_restful

EXPOSE 5290 5290

ENTRYPOINT ["python3.9","/python_api/python-api.py"]
