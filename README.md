# Run commercial Greenplum with Docker

Suppose Centos7 RPM package of Pviotal greenplum5 is downloaded (from https://network.pivotal.io/products/pivotal-gpdb/) and reanmed as **greenplum-db.rpm**. Run following command to build docker image.

```bash
$ git clone https://github.com/lij55/gphost.git
$ cd gphost
# download greenplum-db-5.x.y-rhel7-x86_64.rpm from pivnet and rename it to greenplum-db.rpm
$ docker build . -t mygreenplum
```

Then modify docker-compose.yaml to create required cluster host. Default configure use 2 segment hosts.

```yaml
version: '3'
services:
  mdw:
    hostname: mdw
    image: "mygreenplum"
    volumes:
     - ./gpdata:/home/gpadmin/master
    ports:
     - "5222:22"
     - "5432:5432"
  sdw1:
    hostname: sdw1
    image: "mygreenplum"
    volumes:
     - ./gpdata:/home/gpadmin/data
  sdw2:
    hostname: sdw2
    image: "mygreenplum"
    volumes:
     - ./gpdata:/home/gpadmin/data
```

Create the external volumes and run docker-compose

```bash
mkdir gpdata
docker-compose up -d
```

If you see following messages, it means your hosts are ready to run Greenplum.

```
Creating gphost_sdw2_1 ... done
Creating gphost_sdw1_1 ... done
Creating gphost_mdw_1  ... done
```

Then login to master host of Greenplum with followng command with password `changeme`

```bash
ssh -p 5222 gpadmin@127.0.0.1
```

It contains several script which could help to create configurations of Greenplum. Run following command under folder /home/gpadmin

```bash
source /usr/local/greenplum-db/greenplum_path.sh
./prepare.sh -s 2 -n 1
```

`-s` means there are 2 segment hosts and `-n` means each segment host have 1 primary segment.

It will create several configure files( `gpinitsystem_config`, `env.sh`, `hostfile`) for gpinitsystem. 

Run following command to start Greenplum

```bash
gpinitsystem -a -c gpinitsystem_config
```