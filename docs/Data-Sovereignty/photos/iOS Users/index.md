---
title: iCloud Docker Image
summary: A section of the Wiki Dedicated to showcasing accessible methods of obtaining data sovereignty for individuals.
authors:
- Rastacalavera
---

If you have an iPhone, you likely use iCloud and sync your photos.

If you have a linux machine and not a mac, bringing those photos back to your LAN might be a bit of a headache. 

[Mandrons/icloud-drive-docker](https://github.com/mandarons/icloud-drive-docker) may be an approach  to help alleviate this issue.

Mandron's docker image allows the syncing of an individual's icloud assets onto their local machine.

Syncing everything without specific declarations may not be possible but it is easy to put photos into albums by year and then have the docker container sync those albums to a machine. 

Users should clone the [github](https://github.com/mandarons/icloud-drive-docker.git) to get started but samples of the docker compose, config and environment files are shown below.

A sample compose file is shown below:
```
version: "3.4"
services:
  icloud:
    image: mandarons/icloud-drive
    environment:
      - PUID=<insert the output of `id -u $user`>
      - GUID=<insert the output of `id -g $user`>
    env_file:
      - .env.icloud #should contain ENV_ICLOUD_PASSWORD=<password>
    container_name: icloud
    restart: unless-stopped
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - ${PWD}/icloud/config.yaml:/app/config.yaml
      - ${PWD}/icloud/data:/app/icloud
      - ${PWD}/session_data:/app/session_data
```

The compose file references a configuration and environment file as well. Samples are shown below.

### Config
```
app:
  logger:
    # level - debug, info (default), warning or error
    level: "info"
    # log filename icloud.log (default)
    filename: "icloud.log"
  credentials:
    # iCloud drive username
    username: "please@replace.me"
    # Retry login interval - default is 10 minutes
    retry_login_interval: 600
  # Drive destination
  root: "icloud"
  smtp:
    ## If you want to recieve email notifications about expired/missing 2FA credentials then uncomment
    # email: "user@test.com"
    ## optional, to email address. Default is sender email.
    # to: "receiver@test.com"
    # password:
    # host: "smtp.test.com"
    # port: 587
    # If your email provider doesn't handle TLS
    # no_tls: true
  region: global # For China server users, set this to - china (default: global)
drive:
  destination: "drive"
  remove_obsolete: false
  sync_interval: 300
  filters:
    # File filters to be included in syncing iCloud drive content
    folders:
      - "folder1"
      - "folder2"
      - "folder3"
    file_extensions:
      # File extensions to be included
      - "pdf"
      - "png"
      - "jpg"
      - "jpeg"
photos:
  destination: "photos"
  remove_obsolete: false
  sync_inteval: 500
  filters:
    albums:
      - "album 1"
      - "album2"
    file_sizes: # valid values are original, medium and/or thumb
      - "original"
      # - "medium"
      # - "thumb"
```
### Env file
```
ENV_ICLOUD_PASSWORD=replacewithpassword
```
Once the files are synced locally, users could use other tools like `rsync` and a cron job to sync the folders to other backup locations.