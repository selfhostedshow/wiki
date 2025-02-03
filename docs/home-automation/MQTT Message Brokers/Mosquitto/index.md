# Setup

It is possible to setup a nearly-stateless MQTT broker in docker, with password security.

This required a few steps that were annoying to stub my toe on trying to figure them out.

Here, I have attempted to list them all out.

### Step 0: Be aware that Mosquitto usernames/passwords are sent to the broker in clear text
Per this [link](http://www.steves-internet-guide.com/mqtt-username-password-example/), username and password are sent in clear text

The only way around this is to enable some transport-level security.

Transport-level security is out of scope of this guide.

Do not consider this setup to be Fort Knox.
Anyone with Wireshark could see usernames and passwords in the connection request.
Anyone with Wireshark could see individual messages in clear text.
They could easily start inserting messages into Mosquitto.

### Step 1: review docker compose settings for an overview of the container and the volume mappings

```yaml
# (filename: docker-compose.yaml) 
version: '2.4'
services:
  mqtt-mosquitto:
    image: eclipse-mosquitto:latest
    container_name: mqtt-mosquitto

    # eclipse-mosquitto appears to happily support 10 devices on this amount of memory
    mem_limit: 20m

    # CPU usage has been less than 1% at idle, bursting to 10% on a Raspberry Pi 4
    # so a limit of one entire CPU core should be plenty even for bursty loads
    cpus: 1

    # I have been running eclipse-mosquitto as an ephemeral service with no stateful storage    
    # however, there's a one-time setup step for creating the password file that is easiest to run from inside the container
    # (because the container has all the mosquitto-specific tools it needs inside it.)
    # once mosquitto.passwd is properly set up, you can lock everything down and set all of the volumes as read-only
    volumes:
      - ./config-mosquitto.conf:/mosquitto/config/mosquitto.conf:rw
      - ./password.db:/mosquitto/config/password.db:rw
      
      # - ./data.db:/mosquitto/config/data.db:rw 
      # ^ the database / persistance file, enable if you want persistance


    ports:
      - 1883:1883

#    restart: unless-stopped # Restart settings can of course be configured to your preference

    logging:
      driver: "json-file"
      options:
        max-size: "20m"
        max-file: "5"

```


### Step 2: review config-mosquitto.conf and place next to your docker-compose.yaml file

**note that allow_anonyomus is true; we are going to have to generate the password file for mosquitto to use.**

For more information on available configuration options, [steves-internet-guide](http://www.steves-internet-guide.com/mossquitto-conf-file/) has some very readable documentation


```
# (filename: config-mosquitto.conf) 
#I assume that you do not wish for random people to be able to snoop your home automation traffic or fire random comamnds at your devices
#So, for internal security, our goal will be to turn off allow_anonymous
#but the password file is blank / not correctly generated at first
#which may cause the server to refuse to start, so for the *first* run, you might need to start with allow_anonymous set to true
allow_anonymous false

# The rub is, you have to install mosquitto to get access to the mosquitto_password tool to generate the file... We could do that, but I didn't want to install Mosquitto twice...
# So I'm going to use the mosquitto tools inside the container (yep, they left them in there) to write this password file, from the inside.
# Ye Olde Solo Laproscopic Surgery Trick... 
password_file /mosquitto/config/password.db
#uncomment the above line when the file is available


#format: listener port [optional ip-address]
listener 1883

#this matches the listed defaults, but I wanted them decared for my reference and because they seem like reasonable defaults
max_inflight_messages 20
max_queued_messages 1000

#persistance=false as in 'it will not write to disk, it will run in memory only'.
#Since (1) I don't care about losing a handful of inflight home-automation packets and (2) I want to avoid pointless disk writes and wearing,
#I am fine with turning peristance off...
persistence false

# If you want persistance across reboots, set the above to true and note the filename below

# !! Note !! 
# ...I never actually got persistance to work
# The error message was: 
# `Saving in-memory database to /mosquitto/config/mosquitto.db.`
# `Error: Resource busy.`
persistence_location /mosquitto/config
persistence_file data.db
persistent_client_expiration 3d #how long to retain messages for clients that are not connected
autosave_interval 3 #seconds to wait between intervals of saving retained messages to disk

# for help with these options,  http://www.steves-internet-guide.com/mossquitto-conf-file/   has some very readable documentation 



```




### Step 3: Create a blank password.db file if it does not exist

_so that docker-compose can use the file handle_

`$ touch password.db`

You might need to set the file permissions correctly for docker at this point. 

If persistance is desired, create the database file
`$ touch mosquitto-data.db`

### Step 4: start the container for the first time
e.g. `sudo docker-compose up -d` 

If the container refuses to start without a password file, either 
 - check the configuration file path to the password file is correct, or
 - start the container with allow_anonymous true , create the users as seen below, and then change to allow_anonymous false and restart the container

### Step 5: create the users and passwords from inside the container
 
- create your password using your preferred method... sometimes I use `cat /dev/urandom | head -c 1000 | md5sum ` 
- Do not forget to store your passwords somewhere safe :-)
- To update the password file, we enter the container using `sudo docker exec -it mqtt-mosquitto sh`
- Then we run `mosquitto_passwd -b /mosquitto/config/password.db username password` to add a user with their password
- You can create as many users as you like with this method
- You can remove users with `mosquitto_passwd -D /mosquitto/config/password.db username`
- You must reboot the container (or there's a "reload config" command... somewhere) for changes to take effect.
- after exiting the container, you can now `cat` out the contents of `password.db` to see that it now has usernames with hashed passwords in it
- Official documentation [link](https://mosquitto.org/man/mosquitto_passwd-1.html)

### Step 7: Reconfigure container using password mode
- Shut down the container (`sudo docker-compose down`)
- edit config-mosquitto.conf to `allow_anonymous false` 
- Again in config-mosquitto.conf, uncomment the line  `# password_file /mosquitto/config/mosquitto.passwd`
- Start the container (`sudo docker-compose up`)

To view the broker contents while it is running, I used MQTT Explorer on Windows. (Which also has a Linux build, it seems.)
To insert some test records, you could use   
 - MQTT Explorer    
 - Home Assistant's MQTT integration   
 - the command-line `mosquitto_pub` utility    
 - ...or I used what was then called Benthos (now split into competing projects "Bento" and "Redpanda Connect")   

### Step 8: make your container even more stateless
Set the docker compose volumes to readonly (ro) rather than read-write(rw), which would make your message broker entirely ephemeral.
