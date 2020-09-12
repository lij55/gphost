# Run OSS Greenplum in one step
This repo provide the quickest way to run a Greenplum cluster in a single docker images.
The cluster has 3 primary segment without standby master or mirrors.

```
docker run -d -p 5432:5432 lyasper/greenplum:6
```
Now Greenplum is listening on your localhost 5432 port. Please noted the `gpadmin` users have privilige access without password.  **Never never use this in production**.

# Build your own OSS Geenplum image

If you are interested to build your own images, you may follow below steps.

First step is to clone and checkout the oss branch
```
git clone https://github.com/lij55/gphost.git --branch oss
```

Then build Greenplum binary first
```
export GPTAG=6.10.1
mkdir binary
git clone https://github.com/greenplum-db/gpdb.git --branch ${GPTAG} --single-branch --depth 1 gpdb_${GPTAG}
docker run --rm -u gpadmin -it --workdir /home/gpadmin/gpdb_${GPTAG} -v `pwd`/gpdb_${GPTAG}:/home/gpadmin/gpdb_${GPTAG} -v `pwd`/binary:/opt/greenplum lyasper/gpdev  bash -c "sudo chown -R gpadmin /opt/greenplum && rm -rf /opt/greenplum/* && ./configure --prefix=/opt/greenplum --disable-orca --without-perl --with-python --with-libxml --without-gssapi --disable-pxf --without-zstd&& make -j8 && make install"
```

You may change the value of GPTAG to the version that you need. Please don't change the name of `binary` which is for the build result.

Now its time to build the image
```
docker build . -t greenplum_${GPTAG}
```