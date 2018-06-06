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
ADD ./start.sh /start.sh
RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN yum -y install bash sudo which openssh-clients \
		net-tools less iproute
RUN yum clean all 

RUN chmod 755 /start.sh
RUN ./sh/start.sh gpadmin changeme
RUN mkdir -p /home/gpadmin/.ssh

RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""

ADD ./sh/gpinitsystem_config_template /home/gpadmin/gpinitsystem_config_template
ADD ./sh/prepare.sh /home/gpadmin/prepare.sh
ADD ./sh/cleanup.sh /home/gpadmin/cleanup.sh
ADD ./greenplum-db-5.8.1-rhel7-x86_64.rpm  /home/gpadmin/greenplum-db-5.8.1-rhel7-x86_64.rpm

RUN chmod 755 /home/gpadmin/prepare.sh
RUN chmod 755 /home/gpadmin/cleanup.sh

RUN rpm -i /home/gpadmin/greenplum-db-5.8.1-rhel7-x86_64.rpm
RUN rm -f /home/gpadmin/greenplum-db-5.8.1-rhel7-x86_64.rpm

RUN mkdir -p /home/gpadmin/master /home/gpadmin/data  /home/gpadmin/mirror

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
