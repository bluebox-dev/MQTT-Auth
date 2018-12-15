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
    auth_opt_backends mysql
    auth_opt_host localhost
    auth_opt_port 3306
    auth_opt_dbname  testdb
    auth_opt_user  rootdb
    auth_opt_pass  pwrootdb
    auth_opt_userquery SELECT pw FROM users WHERE username = '%s'
    auth_opt_superquery SELECT COUNT(*) FROM users WHERE username = '%s' AND super = 1
    auth_opt_aclquery SELECT topic FROM acls WHERE (username = '%s') AND (rw >= 1)
    auth_opt_anonusername AnonymouS
    persistence true
    persistence_location /mosquitto/data/
    log_dest file /mosquitto/log/mosquitto.log
```
Can you used file follow me: [mosquitto.conf](https://github.com/bluebox-dev/MQTT-Auth/blob/master/mosquitto.conf)
### MySQL
Assuming the following database tables:
```
    mysql> SELECT * FROM users;
    +----+----------+---------------------------------------------------------------------+-------+
    | id | username | pw                                                                  | super |
    +----+----------+---------------------------------------------------------------------+-------+
    |  1 | user1    | PBKDF2$sha256$901$R0Df2G5E4xreB4o1$GXFLLyZGADTnWwp39eZaw7HB5qg4oYSq |     0 |
    |  2 | root     | PBKDF2$sha256$901$R0Df2G5E4xreB4o1$GXFLLyZGADTnWwp39eZaw7HB5qg4oYSq |     1 |
    +----+----------+---------------------------------------------------------------------+-------+

    mysql> SELECT * FROM acls;
    +----+----------+-------------------+----+
    | id | username | topic             | rw |
    +----+----------+-------------------+----+
    |  1 | user1    | test1             |  1 |
    |  2 | root     | test2             |  1 |
    +----+----------+-------------------+----+
```
Can you load file database follow me: [database.sql]()
>```Pw:``` want to [Create Pw](https://github.com/jpmens/mosquitto-auth-plug/blob/master/np.c)
```
    Exemple: "password"
    Create to => PBKDF2$sha256$901$R0Df2G5E4xreB4o1$GXFLLyZGADTnWwp39eZaw7HB5qg4oYSq
```
## Run
Run a container followed with command:

>**Option1 MQTT only Use docker :**

    docker run  -p 1883:1883 -d -v mosquitto.conf:/mosquitto/config/mosquitto.conf blueboxdev/mqtt-auth

>**Option2 MQTT-Auth Use docker link database :**

    docker run  -p 1883:1883  -d --link testsql:db -v mosquitto.conf:/mosquitto/config/mosquitto.conf  -v log:/mosquitto/log -v data:/mosquitto/data blueboxdev/mqtt-auth

* ```Check IP Docker MySQL``` for edit ip to file mosquitto.conf.

*```-p port``` is  port ```default:1883``` from docker link with localhost.

*```-v volume``` is volume from docker link with localhost ```$PATH: var/lib/docker/volume/```.

*```--link namedabase:db``` is volume from docker dababase.
