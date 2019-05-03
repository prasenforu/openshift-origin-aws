# Centralized Kubernetes Logging with Graylog & FluentBit

Centralized logging in Kubernetes consists in having a daemon set for a logging agent, that dispatches Docker logs in one or several stores. Graylog is a leading centralized log management solution built to open standards for capturing, storing, and enabling real-time analysis of terabytes of machine data. Its a better user experience by making analysis ridiculously fast, efficient, cost-effective, and flexible. 

## Architecture

Graylog is a Java server that uses Elastic Search to store log entries. It also relies on MongoDB, to store metadata (Graylog users, permissions, dashboards, etc). Interesting part is that only Graylog interacts with the logging agents. Graylog manages the storage in Elastic Search, the dashboards and user permissions. Elastic Search should not be accessed directly. Graylog provides a web console and a REST API. So, everything feasible in the console can be done with a REST client.

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


A K8s configuration to install and configure Fluent Bit as a daemon set.  
Fluent Bit collects only Docker logs, gets K8s metadata, builds a GEF message
and sends it to a Graylog server.

* Update the **fluent-bit-configmap.yaml** file.
  Replace **192.168.1.18** with the IP address of your Graylog server.
* Then execute the **deploy.sh** script.
