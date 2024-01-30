FROM lyasper/gphost:kylin
COPY piedb-*.rpm /home/gpadmin/piedb.rpm
RUN yum install -y /home/gpadmin/piedb.rpm && rm -f /home/gpadmin/piedb.rpm
RUN chown -R gpadmin /opt/pie*
