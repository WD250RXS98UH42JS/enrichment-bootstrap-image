FROM docker.elastic.co/elasticsearch/elasticsearch:7.8.0
USER root
RUN yum clean metadata && yum install -y epel-release && yum install -y python-pip && yum install -y openssl && yum install -y jq && pip install requests
COPY ./scripts/* /scripts/
WORKDIR /scripts
RUN chmod +x ./* && chown -R 1000:1000 ./*
USER 1000
ENTRYPOINT ["/bin/sh"]
