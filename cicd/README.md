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

<p align="center">
  <img src="https://github.com/prasenforu/openshift-origin-aws/blob/master/cicd/concourse.png">
</p>

###### Start download concourse CLI (fly), to install the Concourse CLI (fly) on your system, click on the Linux logo to download, and run the following commands…
```
$ cd ~/Downloads/
$ install fly /usr/local/sbin

$ which fly
/usr/local/sbin/fly

$ fly -v
3.14.0
```

###### Login using the fly login command.

```
$ fly login -t hello -c http://<docker host>:8080
logging in to team 'main'

target saved
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

