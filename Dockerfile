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
ADD ./sh/start.sh /start.sh
RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN yum -y install bash sudo
RUN yum install -y epel-release  which openssh-clients \
		net-tools less iproute m4 libevent apr-util
RUN yum install -y python-pip python-psutil
#RUN pip install --no-cache-dir lockfile paramiko setuptools
RUN yum clean all 
RUN rm -rf /var/cache/yum

RUN chmod 755 /start.sh
RUN /start.sh gpadmin changeme
RUN mkdir -p /home/gpadmin/.ssh

RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""

ADD ./binary /opt/greenplum
ADD ./sh/init.sh /init.sh
#RUN mkdir -p /home/gpadmin/gpdata

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh

EXPOSE 5432/tcp
ENTRYPOINT ["runuser", "-l", "gpadmin", "-c", "/init.sh"]
