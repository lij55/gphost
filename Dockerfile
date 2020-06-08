FROM lyasper/sshd:centos7
MAINTAINER Jasper Li <jasli@pivotal.io>

RUN yum -y update && yum -y install which openssh-clients \
    net-tools less iproute \
    && yum clean all 

RUN mkdir -p /home/gpadmin/.ssh

RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""
RUN cp /home/gpadmin/.ssh/id_rsa.pub /home/gpadmin/.ssh/authorized_keys
RUN chmod 0400 /home/gpadmin/.ssh/authorized_keys

ADD ./sh/gpinitsystem_config_template /home/gpadmin/artifact/gpinitsystem_config_template
COPY sh/*.py sh/*.sh /home/gpadmin/artifact/
RUN chmod 755 /home/gpadmin/artifact/*.sh

COPY sh/config /home/gpadmin/.ssh/config
RUN chmod 0400 /home/gpadmin/.ssh/config

RUN mkdir -p /home/gpadmin/master /home/gpadmin/data  /home/gpadmin/mirror

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh
