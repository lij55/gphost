# Run Greenplum cluster in docker

Suppose prebuild Greenplum is copied in folder **greenplum-db**. This folder will be mounted to folder /usr/local/gpdb. Please modify the path in greenplum_path.sh if needed. Run following command to build docker image first. Remember to give it a easier name to remember.

```bash
docker build . -t mygreenplum
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

Run with docker-compose

```bash
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
source /usr/local/gpdb/greenplum_path.sh
./prepare.sh -s 2 -n 1
```

It will create several configure files() `gpinitsystem_config`, `env.sh`, `hostfile`) for gpinitsystem. Then setup password-less login for Greenplum.

```bash
gpssh-exkeys -f hostfile
```

Run following command to start Greenplum

```bash
gpinitsystem -a -c gpinitsystem_config
```

