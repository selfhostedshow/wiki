---
title: Automate Publish / Deploy with Github Actions
summary: A guide on how to automate deployments to remote hosts from GitHub using its Actions
date: 2021-06-24
authors:
  - Adam Spann
---

Setting up GitHub to be able to push a repository to a remote server.

## The Idea
The basic idea is pretty simple. Push updates to your GitHub repo. This will then cause GitHub to trigger an action that will push the updates to a second remote git host. You could then have a hook trigger on this second host to do local actions. This will use the [actions/checkout](https://github.com/marketplace/actions/checkout) and [shimataro/install-ssh-key](https://github.com/marketplace/actions/install-ssh-key) actions.

!!! note
    This could be adjusted to be triggered from other actions.

### Requirements
- Actions must be done by unprivileged users.
- Connect over SSH

## Getting Everything we Need

### SSH

1. We need to generate a new ssh key pair. For simplicity I went with the standard **rsa** with **4096**. You are free to use other options if you prefer.

```shell
ssh-keygen -t rsa -b 4096 -C "[identifier]@linode" -f linode
```

This creates two files. **linode** the private key. The one we need to keep really safe. And **linode.pub** the public key that we usually share.  
Things are going to be a little different here since we are actually going to put the private key into GitHub as a **repository** secret. And add the public key to the remote, linode, server.

Before we do that we also need to get some information about the destination server. We need the information that would normally be stored in the **known_hosts** file when we connect to a remote server using standard **ssh**

We can get this information with:
```shell
ssh-keyscan -t rsa [host address/IP address]
```
You should see that I used `-t rsa` here because my **ssh** keys are also `rsa`.

-----

2. Add these **ssh** details to our GitHub repo.
We have to open our repo on GitHub and add our secrets to the repo we will be pushing to.

Access **Settings** -> **Secrets** and create the following two secrets. Using the **New Respository Secret** button.

Name: LINODE_KEY  
Contents:
```shell
-----BEGIN OPENSSH PRIVATE KEY-----
--snip--
-----END OPENSSH PRIVATE KEY-----
```

I know this looks odd but, Github will keep this safe. And I would use a unique key anyway. Just in case you need to burn it in the future.

Next we need to add the second secret.

Name: LINODE_KNOWN_HOSTS  
Contents: This will be the output you get from the `ssh-keyscan` command listed earlier.

-----
3. We next need to add the contents of `linode.pub` to the remote server's `authorized_keys` under `.ssh` for the user we plan to connect as. There are lots of guides online for this.


## GitHub Action

At this point we can start putting the GitHub Action together. We do this under `.github/workflows/`

```yaml
name: Linode Push Update

on:
  push:
    branches:
      - master

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: Prepare ssh keys
      uses: shimataro/ssh-key-action@v2
      with:
        key: ${{ secrets.LINODE_KEY }}
        known_hosts: ${{ secrets.LINODE_KNOWN_HOSTS }}
        
    - name: Checkout the Repo
      uses: actions/checkout@v2
      with:
        ssh-key: ${{ secrets.LINODE_KEY }}
        fetch-depth: 0
        ref: master
    - name: Push to Linode
      run: |
        git config user.name github-actions
        git config user.email github-actions@github.com
        git remote add prod ssh://[username]@[host]:/var/repos/[remote-repo-name].git
        git push prod
```

Most of this is pretty straight forward. But I was missing an important step initially. That is the use to of the **shimataro/ssh-key-action**. This action is needed as it will add our secret **ssh** data so that we authenticate when we connect to the remote server. It adds the **LINODE_KEY** and the **LINODE_KNOWN_HOSTS** information.

If you are wondering about the **remote-repo-name.git** this is because it should be created as a **bare** git repo.   
