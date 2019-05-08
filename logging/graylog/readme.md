# Centralized Kubernetes Logging with Graylog & FluentBit

Centralized logging in Kubernetes consists in having a daemon set for a logging agent, that dispatches Docker logs in one or several stores. Graylog is a leading centralized log management solution built to open standards for capturing, storing, and enabling real-time analysis of terabytes of machine data. Its a better user experience by making analysis ridiculously fast, efficient, cost-effective, and flexible. 

## Architecture

Graylog is a Java server that uses Elastic Search to store log entries. It also relies on MongoDB, to store metadata (Graylog users, permissions, dashboards, etc). Interesting part is that only Graylog interacts with the logging agents. Graylog manages the storage in Elastic Search, the dashboards and user permissions. Elastic Search should not be accessed directly. Graylog provides a web console and a REST API. So, everything feasible in the console can be done with a REST client.

<p align="center">
  <img src="https://github.com/prasenforu/openshift-origin-aws/blob/master/logging/graylog/graylog-arch.png">
</p>

#### Graylog concepts

- input

An input is a listener to receive GELF messages. You can create one by using the ```System > Inputs``` menu. In this example, we create a global one for GELF HTTP (port 12201). There are many options in the creation dialog, including the use of SSL certificates to secure the connection.

- Indices

Graylog indices are abstractions of Elastic indexes. They designate where log entries will be stored. You can associate sharding properties (logical partition of the data), retention delay, replica number (how many instances for every shard) and other stuff to a given index. Every projet should have its own index: this allows to separate logs from different projects. Use the System > Indices to manage them. A project in production will have its own index, with a bigger retention delay and several replicas, while a developement one will have shorter retention and a single replica (it is not a big issue if these logs are lost).

- Streams

A stream is a routing rule. They can be defined in the Streams menu. When a (GELF) message is received by the input, it tries to match it against a stream. If a match is found, the message is redirected into a given index. When you create a stream for a project, make sure to check the Remove matches from ‘All messages’ stream option. This way, the log entry will only be present in a single stream. Otherwise, it will be present in both the specific stream and the default (global) one.

The stream needs a single rule, with an exact match on the K8s namespace (in our example).
Again, this information is contained in the GELF message. Notice that the field is _k8s_namespace in the GELF message, but Graylog only displays k8s_namespace in the proposals. The initial underscore is in fact present, even if not displayed.

- Dashboards

Graylog’s web console allows to build and display dashboards. Make sure to restrict a dashboard to a given stream (and thus index). Like for the stream, there should be a dashboard per namespace. Using the K8s namespace as a prefix is a good option.

- Roles

Graylog allows to define roles. A role is a simple name, coupled to permissions (roles are a group of permissions). You can thus allow a given role to access (read) or modify (write) streams and dashboards. For a project, we need read permissions on the stream, and write permissions on the dashboard. This way, users with this role will be able to view dashboards with their data, and potentially modifying them if they want. Roles and users can be managed in the System > Authentication menu.

- Users

Apart the global administrators, all the users should be attached to roles. These roles will define which projects they can access. You can consider them as groups. When a user logs in, Graylog’s web console displays the right things, based on their permissions.

Creating a user in Graylog, There are two predefined roles: admin and viewer.
Any user must have one of these two roles. He (or she) may have other ones as well. When a user logs in, and that he is not an administrator, then he only has access to what his roles covers.

```Graylog support LDAP authentication mechanisms.```


### Installation

Kubernetes configuration to install and configure Fluent Bit as a daemon set. Fluent Bit collects only Docker logs, gets K8s metadata, builds a GEF message and sends it to a Graylog server. 

Production-grade deployment would require a highly-available cluster, for both ES, MongoDB and Graylog. But for this article, a local installation is enough. A docker-compose file was written to start everything. As ES requires specific configuration of the host, here is the sequence to start it:

#### Step #1

Install Docker-compose as a standalone setup a saperate host and remember the host IP.

```
curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Before running compose run some system configuration.

````
sysctl -w vm.max_map_count=262144
docker-compose -f compose-graylog.yml up -d
```

#### Step #2

Create the namespace in Kubernetes

```kubectl create namespace logging```

Create the namespace in Openshift

```
oc new-project logging
oc patch namespace logging -p '{"metadata": {"annotations": {"openshift.io/node-selector": ""}}}'
```

#### Step #3

Setting up service account in Kubernetes

```kubectl create -f fluent-bit-rbac.yaml```

Setting up service account in Openshift

```
oc create -f fluent-bit-rbac.yaml
oc adm policy add-scc-to-user privileged system:serviceaccount:logging:fluent-bit-sa
```

#### Step #4

Create the config map
Update the fluent-bit-configmap.yaml file. Replace ```<GRAYLOG-SERVER>``` with the IP address of your Graylog server.

```
sed -i 's/GRAYLOG-SERVER/10.138.0.2/g' fluent-bit-configmap.yaml
kubectl create -f fluent-bit-configmap.yaml
```

#### Step #5

As a log collector we are using FluentBit. Create the daemon set.

```kubectl create -f fluent-bit-daemon-set.yaml```

### Verification

- Check all pods are running.
- Log into Graylog Server web console at http://<GRAYLOG-SERVER>:9000 with ```admin/admin``` as credentials. 
  
Those who interested to create a highly available installation can take a look on Graylog’s web site.

##### TIPS

Delete docker volume

```docker system prune -f```

##### Reference

> See [this blog post](https://vzurczak.wordpress.com/?p=781) for more details.
