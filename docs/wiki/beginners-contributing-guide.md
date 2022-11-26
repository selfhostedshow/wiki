# Beginners Contributing Guide

See the [Contribution Guidelines](https://wiki.selfhosted.show/wiki/contributing/) for information and objectives of the wiki.

## Prerequisites:
* Docker is already running in your environment
* You have a [Github](https://github.com) account and are logged in
* This guide was written for linux

__Note__: **This document will use variables throughout make sure to change them as needed.**

### Install Git
This section will install Git.

0. Log in to the your computer or server you are going to use for Git.

0. Type `apt-get install git` git will be installed.

0. Type `git config --global user.email "email@example.com"` to set an email address that will be used when you post to GitHub.

0. Type `git config --global user.name "John Doe"` to set a username that will be used when you post to GitHub.

0. Type `git config --list` to verify the email address and username.

#### Fork & Clone the Self-Hosted Show wiki
This section will Fork the entire Self-Hosted Show wiki to your Github account, and then clone the fork in order to enable local editing.

0. Navigate to the [upstream](https://github.com/selfhostedshow/wiki).

0. Click ![Fork](images/fork.png) in the top right to copy the "wiki" repository to your Github account.

0. [Make sure you have ssh keys added to your account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

0. Log in to your computer or server you are going to use for Git and `cd` to the directory you want to download the wiki repository to.

0. Type `git clone git@github.com:selfhostedshow/wiki.git && cd wiki`.

0. Verify the "master" branch is checked out type `git checkout master`.

0. Type `git remote -v` to verify that the origin site was added.
    
    ```
    origin  https://github.com/GITHUBSUSERNAME/wiki (fetch)  
    ```
    
    ```
    origin  https://github.com/GITHUBSUSERNAME/wiki (push)
    ```

0. Specify a new [upstream](https://github.com/selfhostedshow/wiki) repository that will be synced with this fork, type `git remote add upstream https://github.com/selfhostedshow/wiki`.

0. Verify the new [upstream](https://github.com/selfhostedshow/wiki) repository you've specified for your fork, type `git remote -v`, the output should look like the below.

```bash
origin  https://github.com/GITHUBSUSERNAME/wiki (fetch)
origin  https://github.com/GITHUBSUSERNAME/wiki (push)
upstream        https://github.com/selfhostedshow/wiki (fetch)
upstream        https://github.com/selfhostedshow/wiki (push)
```

#### Start the Wiki Docker Container
This section will start the wiki docker container in the local environment.

__Note__: The below path may be different, depending on where the wiki was cloned to.

__Note__: -f will define a docker-compose file and -d ("detached" mode) will start the wiki it in the background

0. Type `sudo docker-compose -f ~/PATHTOWIKI/wiki/docker-compose.yml up -d` this will start the wiki in docker.

0. Type `docker ps` to verify that the wiki container is running.

0. Navigate to `http://DockerIP:8000` and wiki website will then open.

0. Now edit the wiki site in your editor of choice and when you **save** the file, the site will be updated with the changes that are made enabling real time (more or less) verifying what the site will look like with the changes.

#### Merging a local repository into your Fork

This Section will "merge" the local changes to your fork (your github repo that was made above in [Fork & Clone the Self-Hosted Show wiki](/wiki/beginners-contributing-guide/#11-fork-clone-the-self-hosted-show-wiki))

0. Type `git add example1.md example2.png` to add the changed files to your commit.

0. Type `git commit -m "updated x,y,z"` to commit the changes to your fork with comments.

0. Type  `git push origin master` to push your commit to your fork.

#### Make a New Pull Request on GitHub

This section will create a new pull request from your Github repo to the [Upstream](https://github.com/selfhostedshow/wiki) wiki site.

0. Navigate to the Github [wiki](https://github.com/selfhostedshow/wiki) web interface.

0. Click ![newpullrequest](images/newpullrequrest.png) in the top(ish) left, verify the the branch is set to "master". 

0. Under Compare changes click "compare across forks" link, verify the **base** repository is the [upstream](https://github.com/selfhostedshow/wiki) site and the head repository is your repo.

0. The changes that were made should come automatically, make the comment succinct and meaningful.

0. Submit a pull request by clicking ![createpullrequest](images/createpullrequest.png).

0. The commit has now been added to the pull request the Wiki-Admins will review and if approved will get pushed to the master branch for publishing.

### Syncing a Fork
This Section will "pull" from the [upstream](https://github.com/selfhostedshow/wiki) repository to your local repository. **This should be done every time before you make any changes to your local wiki in order to make sure everything is in sync**.

0. Verify you are in the wiki directory.

0. Type `git fetch upstream` to fetch the branches and their respective commits from the upstream repository

0. Verify the "master" branch is checked out type `git checkout master`

0. Type `git merge upstream/master` to bring your local branch in to sync with the [upstream](https://github.com/selfhostedshow/wiki) repository.

## Recommended Reading/Watching
* [GitHub WorkFlow Introduction](https://guides.github.com/introduction/flow/)
* [GitHub Training & Guides](https://www.youtube.com/githubguides)
* [Docker Compose Cheatsheet](https://devhints.io/docker-compose) 
* [Docker Getting Started](https://docs.docker.com/compose/gettingstarted/) 
* [Markdown -- Github Help](https://help.github.com/en/github/writing-on-github)
* [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
