# Openshift Billing

Metering records historical cluster usage, and can generate usage reports showing usage breakdowns by pod or namespace over arbitrary time periods.
Data gathered from a perspective of operations is usually focused on a current window of time; the last hour, the last 24 hours, and/or the last 7 days. This is based on opensource tool ```operator-metering```

## Installation

This installatation based on Openshit 3.11.

### Step #1

Create ```metering-custom.yaml``` file and edit following value based on output of command.

```
        htpasswdData: |
          testuser:{SHA}y/2sYAj5yrQIN4TL0YdPdmGNKpc=
        cookieSeed: "t6JA9vA0cv4up/BGyI47+L7yLKTpX1s7"
```
###### Step -A)

htpasswdData can contain htpasswd file contents for allowing auth using a static list of usernames and their password hashes.
Generate htpasswdData using: 

```htpasswd -nb -s testuser password123```

###### Step -B)

cookieSeed is used to protect the cookie created if accessing the API using browser.
Generate a 32 character random string using a command of your choice

```openssl rand -base64 32 | head -c32; echo```

### Step #2


### Step #3



### Step #4


