---
title: Automate Actions on your Remote Server from a Push
summary: Here we will setup a bare git repo with a post-receive hook to automate tasks after it receives a git push.
date: 2021-6-24
authors:
  - Adam Spann
---

## Concept
In this write up. I will look at the following.  

1. Setup a bare git repo to receive pushes from another git repo.
2. Have the remote repo trigger a script locally.

Keep in mind that best practices would be to ensure that you are using the least privileged use you can get away with.

## Setup the Bare Git Repo

This is fairly simple really. Decide where you want the repo and then create to directory for it. For this example I will be starting from `/var`

If you are unable to create the directory where you want as a standard user. Use `sudo` to create the directory and than change ownership. Given that `/var` is usually owned by **root** we can do the following.

```shell
sudo mkdir -p /var/repos/[repo-name].git
sudo chown [myuser]:[myuser] /var/repos/[repo-name].git
cd /var/repos/[repo-name].git
git --bare init
```
Be sure to run `git --bare init` as the user that will be using this directory to ensure the correct permissions and that you are not **root**.

## Set the Repo up to run a Script when things are Received

### Creating the post-receive file.
For the purposes of demonstration. I will how have I have a Hugo site generated.
 
Inside your new repo directory issue the following commands
```shell
cd hooks
touch post-receive
chmod +x post-receive
```
!!! note Permissions

    The script needs to be executable.
    
This is the contents of my own `post-receive` script.

```shell
#!/bin/bash

DOMAIN=REDACTED
GIT_REPO=/var/repos/[repo-name].git
WORKING_DIRECTORY=/tmp/$DOMAIN
PUBLIC_WWW=/var/www/$DOMAIN
BACKUP_WWW=/tmp/$DOMAIN-backup

set -e

rm -rf $WORKING_DIRECTORY
rsync -aqz $PUBLIC_WWW/ $BACKUP_WWW
trap "echo 'A problem occurred.  Reverting to backup.'; rsync -aqz --del $BACKUP_WWW/ $PUBLIC_WWW; rm -rf $WORKING_DIRECTORY" EXIT

git clone $GIT_REPO $WORKING_DIRECTORY
# Add Theme and other submodules
git clone https://github.com/halogenica/beautifulhugo $WORKING_DIRECTORY/themes/beautifulhugo
# This RM command should be replaced. with an rsync ... --delete source destination
rm -rf $PUBLIC_WWW/*
hugo -s $WORKING_DIRECTORY -d $PUBLIC_WWW -b "http://${DOMAIN}"
rm -rf $WORKING_DIRECTORY
trap - EXIT
```
