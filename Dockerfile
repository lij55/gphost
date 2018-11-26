# enhanced by Jasper Li <jasli@pivotal.io> from 
#  https://github.com/CentOS/CentOS-Dockerfiles
#
# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>

FROM centos:centos7
MAINTAINER Jasper Li <jasli@pivotal.io>

RUN yum -y update
RUN yum -y install openssh-server passwd 
RUN yum -y install bash sudo which openssh-clients \
		net-tools less iproute
RUN yum clean all 

COPY ./sh/start /start
RUN chmod 700 /start

RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN /start gpadmin changeme

RUN mkdir -p /home/gpadmin/.ssh

RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""
RUN cp /home/gpadmin/.ssh/id_rsa.pub /home/gpadmin/.ssh/authorized_keys
RUN chmod 0400 /home/gpadmin/.ssh/authorized_keys

ADD ./sh/gpinitsystem_config_template /home/gpadmin/artifact/gpinitsystem_config_template
ADD ./sh/config /home/gpadmin/.ssh/config
ADD ./greenplum-db.rpm  /home/gpadmin/greenplum-db.rpm
COPY sh/*.py sh/*.sh /home/gpadmin/artifact/
COPY madlib-*-gp5-rhel7-x86_64.gppkg /home/gpadmin/artifact/madlib.gppkg

RUN chmod 755 /home/gpadmin/artifact/*.sh

COPY sh/config /home/gpadmin/.ssh/config
RUN chmod 0400 /home/gpadmin/.ssh/config

RUN rpm -i /home/gpadmin/greenplum-db.rpm
RUN rm -f /home/gpadmin/greenplum-db.rpm

RUN mkdir -p /home/gpadmin/master /home/gpadmin/data  /home/gpadmin/mirror

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh
RUN chown -R gpadmin /usr/local/greenplum-db*

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
