# MQTT-Auth use MySQL Database
## Quick Reference in Docker
* **Source of this my project description:**
[GitHub](https://github.com/bluebox-dev/MQTT-Auth)
* **Docker Reference:**
[eclipse-mosquitto](https://github.com/eclipse/mosquitto/blob/a0a37d385db4421d7151f1fe969a7b00d4516c24/docker/1.5/Dockerfile)
* **Plugin-Auth Reference:**
[mosquitto-auth-plug](https://github.com/jpmens/mosquitto-auth-plug/blob/master/README.md)

## How to use this image
### Directories
Three directories have been created in the image to be used for configuration, persistent storage and logs.
```
    /mosquitto/config
    /mosquitto/data
    /mosquitto/log
```
### Configuration
Assuming the following **Add Config** as Auth in mosquitto.conf :
```
    auth_plugin /mosquitto/config/auth-plug.so
    auth_opt_host localhost
    auth_opt_port 3306
    auth_opt_dbname  testdb
    auth_opt_user  rootdb
    auth_opt_pass  pwrootdb
    auth_opt_userquery SELECT pw FROM users WHERE username = '%s'
    auth_opt_superquery SELECT COUNT(*) FROM users WHERE username = '%s' AND super = 1
    auth_opt_aclquery SELECT topic FROM acls WHERE (username = '%s') AND (rw >= 1)
    auth_opt_anonusername AnonymouS
```
Can you used file follow me: [mosquitto.conf](http://en.wikipedia.org/wiki/Markdown)
### MySQL
Assuming the following database tables:
```
    mysql> SELECT * FROM users;
    +----+----------+---------------------------------------------------------------------+-------+
    | id | username | pw                                                                  | super |
    +----+----------+---------------------------------------------------------------------+-------+
    |  1 | user1    | PBKDF2$sha256$901$x8mf3JIFTUFU9C23$Mid2xcgTrKBfBdye6W/4hE3GKeksu00+ |     0 |
    |  2 | root     | PBKDF2$sha256$901$XPkOwNbd05p5XsUn$1uPtR6hMKBedWE44nqdVg+2NPKvyGst8 |     1 |
    +----+----------+---------------------------------------------------------------------+-------+

    mysql> SELECT * FROM acls;
    +----+----------+-------------------+----+
    | id | username | topic             | rw |
    +----+----------+-------------------+----+
    |  1 | user1    | test1             |  1 |
    |  2 | root     | test2             |  1 |
    +----+----------+-------------------+----+
```
Can you load file database follow me: [database.csv](http://en.wikipedia.org/wiki/Markdown)
## Run
Run a container followed with command:

**Option MQTT only:**

    docker run  -p 1883:1883 -d -v mosquitto.conf:/mosquitto/config/mosquitto.conf blueboxdev/mqtt-auth

**Option1 MQTT-Auth Use localhost database :**

    docker run  -p 1883:1883 -p 3306:3306 -d -v mosquitto.conf:/mosquitto/config/mosquitto.conf blueboxdev/mqtt-auth

**Option2 MQTT-Auth Use docker link database :**

    docker run  -p 1883:1883  -d --link testsql:db -v mosquitto.conf:/mosquitto/config/mosquitto.conf  -v log:/mosquitto/log -v data:/mosquitto/data blueboxdev/mqtt-auth

>```-p port``` is  port ```default:1883``` from docker link with localhost.

>```-v volume``` is volume from docker link with localhost ```$PATH: var/lib/docker/volume/```.

>```--link namedabase:db``` is volume from docker dababase.
