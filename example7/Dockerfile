FROM lyasper/gphost
COPY greenplum-db-7.*-x86_64.rpm /home/gpadmin/greenplum-db.rpm
RUN yum install -y /home/gpadmin/greenplum-db.rpm
RUN chown -R gpadmin /usr/local/greenplum-db*
RUN rm -f /home/gpadmin/greenplum-db.rpm
