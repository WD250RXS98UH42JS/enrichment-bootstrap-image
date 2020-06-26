FROM docker.elastic.co/elasticsearch/elasticsearch:7.8.0
COPY ./scripts/* /scripts/
WORKDIR /scripts
USER root
RUN yum install -y epel-release && yum install -y python-pip && pip install requests && chmod +x ./* && chown -R 1000:1000 ./*
USER 1000
ENTRYPOINT ["/bin/sh"]
