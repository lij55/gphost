# enhanced by Jasper Li <jasli@pivotal.io> from 
#  https://github.com/CentOS/CentOS-Dockerfiles
#
# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>

FROM centos:centos7

RUN yum -y update
RUN yum -y install openssh-server passwd bash sudo \
        epel-release xerces-c which openssh-clients \
		net-tools less iproute m4 libevent apr-util \
		python-pip python-psutil python2-lockfile python-paramiko \
		&& yum clean all && rm -rf /var/cache/yum

ADD ./sh/start.sh /start.sh
RUN /start.sh gpadmin changeme

RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN mkdir -p /home/gpadmin/.ssh
RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""

ADD ./binary /opt/greenplum
ADD ./sh/init.sh /init.sh
RUN echo source /opt/greenplum/greenplum_path.sh >> /home/gpadmin/.bashrc

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh

EXPOSE 5432/tcp
ENTRYPOINT ["runuser", "-l", "gpadmin", "-c", "/init.sh"]
