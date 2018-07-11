# Clair Image scanner
Clair is an open source project for the static analysis of vulnerabilities in appcation and docker containers.

## Overview
Clair is an open source project for the static analysis of vulnerabilities for docker containers.
Vulnerability data is continuously imported from a known set of sources and correlated with the indexed contents of container images in order to produce lists of vulnerabilities that threaten a container. When vulnerability data changes upstream, the previous state and new state of the vulnerability along with the images they affect can be sent via webhook to a configured endpoint.

### INSTALLATION

#### Step 1 - Download Clair's Docker Compose File and Config file.

Clair requires a Postgres instance for storing the CVE data and it's service that will scan Docker Images for vulnerabilities. 
 
```
	curl -OL https://raw.githubusercontent.com/coreos/clair/master/contrib/compose/docker-compose.yml
```

#### Step 2 Download Clair's Config file.


The Clair configuration defines how Images should be scanned. Download it with:

```
	mkdir clair_config
	curl -L https://raw.githubusercontent.com/coreos/clair/master/config.yaml.sample -o clair_config/config.yaml
```

#### Step 3 Update Config Clair's Config file.
 
Set the version of Clair to the last stable release and the default database password. 

```
	sed 's/clair-git:latest/clair:v2.0.1/' -i docker-compose.yml
  	sed 's/host=localhost/host=postgres password=password/' -i clair_config/config.yaml
```

#### Step 4 Start DB

```
	docker-compose up -d postgres
```

-----

#### Step 5 Populate DB

Download and load the CVE details for Clair to use.

```
curl -LO https://gist.githubusercontent.com/BenHall/34ae4e6129d81f871e353c63b6a869a7/raw/5818fba954b0b00352d07771fabab6b9daba5510/clair.sql
docker run -it \
    -v $(pwd):/sql/ \
    --network "${USER}_default" \
    --link clair_postgres:clair_postgres \
    postgres:latest \
        bash -c "PGPASSWORD=password psql -h clair_postgres -U postgres < /sql/clair.sql"
```

##### Note: Clair would do this by default, but can take 10/15 minutes to download.

------

#### Step 6 - Deploy Clair 

With the DB populated, start the Clair service.

```
docker-compose up -d clair

```

We can now send it Docker Images to scan and return which vulnerabilities it contains.
------

#### Now Docker Images need to scan and return which vulnerabilities it contains.

Clair works by accepting Image Layers via a HTTP API. To scan all the layers, we need an way to send each layer and aggregate the respond. 
Klar is a simple tool to analyze images stored in a private or public Docker registry for security vulnerabilities using Clair.
Download the latest release from Github. 


```
	curl -L https://github.com/optiopay/klar/releases/download/v1.5/klar-1.5-linux-amd64 -o /usr/local/bin/klar && chmod +x $_

```


#### Using klar, we can now point it at images and see what vulnerabilities they contain, for example quay.io/coreos/clair:v2.0.1.

```
	CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Low CLAIR_THRESHOLD=10 klar quay.io/coreos/clair:v2.0.1
```
