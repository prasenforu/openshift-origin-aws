# Concourse CI/CD
An opensource CI/CD tool, simple primitives (Resources, Jobs, Tasks), a heavy emphasis on continuous workflows defined by YAML.

## Overview
Concourse is an open-source continuous thing-doer. Built on the simple mechanics of resources, tasks, and jobs, Concourse presents a general approach to automation that makes it great for CI/CD.


#### Installation

##### Step 1

```
wget -nv -O docker-compose.yml https://concourse-ci.org/docker-compose.yml

curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/sbin/docker-compose

chmod +x /usr/local/sbin/docker-compose
```
##### Step 2
```
vi docker-compose.yml
```
###### Edit docker-compose.yml file as per requirement

##### Step 3
```
docker-compose up -d
```

##### Step 4

Check its running ..
```
docker ps -a
```
#### Accessing Concourse

```
http://<docker host>:8080/).
```

###### Start download concourse CLI (fly)
```
docker-compose stop
```

###### To install the Concourse CLI (fly) on your system, click on the Linux logo to download, and run the following commands…
```
$ cd ~/Downloads/
$ install fly /usr/local/sbin

$ which fly
/usr/local/sbin/fly

$ fly -v
3.14.0
```

###### Login using the fly login command.

To change Harbor's configuration, first stop existing Harbor instance and update harbor.cfg. Then run prepare script to populate the configuration. Finally re-create and start Harbor's instance:

```
docker-compose down -v
vi harbor.cfg
prepare
docker-compose up -d
```
###### Removing Harbor's containers while keeping the image data and Harbor's database files on the file system:

```
$ fly login -t hello -c http://192.168.99.100:8080
logging in to team 'main'

target saved
```

###### Removing Harbor's database and image data (for a clean re-installation):

```
rm -r /data/database
rm -r /data/registry
```

##### Setting up a Pipeline (example)

```
wget -nv https://raw.githubusercontent.com/concourse/testflight/master/pipelines/fixtures/simple.yml

fly -t hello set-pipeline -p hello-world -c simple.yml 
```
You’ll see a single job pipeline called “simple” and the top navigation will be blue. This color confirms that you’re pipeline is paused.

##### At this point, we’re able to do conduct actions like unpause-pipeline and trigger-pipeline via the web interface or fly.

```
fly -t hello unpause-pipeline -p hello-world
```
The navigation bar should lose its blue colouring at this point. Indicating that it’s ready to run jobs.

##### This pipeline doesn’t have any Resources that can trigger the “simple” job, so we’ll use fly trigger-job to do it manually.

```
fly -t hello trigger-job -j hello-world/simple
```

