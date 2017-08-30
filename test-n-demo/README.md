# Setup Grafana behind apache, authentication using htpasswd

### 1. 	Create a file httpd.conf with the following contents

```
ServerRoot "/usr/local/apache2"
Listen 80
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule headers_module modules/mod_headers.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
<IfModule unixd_module>
User daemon
Group daemon
</IfModule>
ServerAdmin you@example.com
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/usr/local/apache2/htdocs"
ErrorLog /proc/self/fd/2
LogLevel error
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog /proc/self/fd/1 common
</IfModule>
<Proxy *>
    AuthType Basic
    AuthName GrafanaAuthProxy
    AuthBasicProvider file
    AuthUserFile /tmp/htpasswd
    Require valid-user
    RewriteEngine On
    RewriteRule .* - [E=PROXY_USER:%{LA-U:REMOTE_USER},NS]
    RequestHeader set X-WEBAUTH-USER "%{PROXY_USER}e"
</Proxy>
RequestHeader unset Authorization
ProxyRequests Off
ProxyPass / http://grafana:3000/
ProxyPassReverse / http://grafana:3000/

```

### 2.	Create a file grafana.ini with the following contents

```

[users]
allow_sign_up = false
auto_assign_org = true
auto_assign_org_role = Editor

[auth.proxy]
enabled = true
header_name = X-WEBAUTH-USER
header_property = username
auto_sign_up = true

```

### 3. 	Launch the Grafana container, using our custom grafana.ini to replace /etc/grafana/grafana.ini and for persistent storage mounting /var/lib/grafana folder 

#### Note : We dont expose any ports for this container as it will only be connected to by our Apache container.

```
docker run -d --restart always -v /var/lib/grafana:/var/lib/grafana -v $(pwd)/grafana.ini:/etc/grafana/grafana.ini --name grafana grafana/grafana
```
### 4. 	Launch the httpd container using our custom httpd.conf and our htpasswd file. The container will listen on port 80, and we create a link to the grafana container. So that this container can resolve the hostname grafana to the grafana container’s ip address.

#### Note :  Here I am mounting container htpasswd file from host (in my case /etc/origin/master/users.htpasswd)
```
docker run -d --restart always -p 80:80 --link grafana:grafana -v $(pwd)/httpd.conf:/usr/local/apache2/conf/httpd.conf -v /etc/origin/master/users.htpasswd:/tmp/htpasswd httpd:2.4
```

### 5. 	Once Grafana and Apache containers running, you can now connect to http://localhost/ and log in using the username/password we created in the htpasswd file.
