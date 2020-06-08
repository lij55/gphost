FROM lyasper/gphost
COPY greenplum-db-5.*-rhel7-x86_64.rpm /home/gpadmin/greenplum-db.rpm
RUN rpm -i /home/gpadmin/greenplum-db.rpm
RUN chown -R gpadmin /usr/local/greenplum-db*
RUN rm -f /home/gpadmin/greenplum-db.rpm
