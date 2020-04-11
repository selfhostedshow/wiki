# Contributing to the Self Hosted Show Wiki


## Objectives of This Wiki

To contribute well, you need to understand what the objectives are behind this wiki.

What we are trying to create:

- A compilation of tools, tips and tricks for self-hosting specific applications.
- A place where beginners and experts can learn about how to quickly, efficiently and securely deploy applications on their own server(s).
- Snippets that people can quickly reference in deploying applications.
- A hub for quality documentation (to the extent possible).

What we are not trying to do:

- Be another large list of self-hosted tools. See [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) for a comprehensive list of self-hosted applications.
- Be a hub for script kitties. People should _learn_ from documentation here not just come here to copy/paste. Snippets are important but should be documented properly.
- Promote or encourage insecure, sloppy or any undesirable systems administration practices such as:
    - Executing remote code by `curl`-ing an untrusted script and piping it to `sudo bash`: `curl https://example.com/awesomescript.sh | sudo bash`
    - Installing additional bloat within a container


We want to encourage the usage of Devops tooling such as config management, containerisation and automation. This will improve the ease of use for all and increase code reuse amongst the community ultimately leading to an easier time for all.

## Directory Layout:

The `docs` folder in the root of the repository is where wiki content should be placed.

The following example directory layout should be adhered to when contributing:

`docs/category/application/index.md`

Additional, more specific articles relating to that same topic should be named differently:

`docs/category/application/specific-topic.md`

For example, if I wanted to add a brand new, generic article for Home Assistant, my layout would be this:

`docs/home-automation/home-assistant/index.md`


For an additional article that is more specific I could name it like so:

`docs/home-automation/home-assistant/docker-deployment.md`


Any images embedded in an article should be placed within a folder called `images` within the same directory:

`docs/home-automation/home-assistant/images/example.png`


Any other relevant resources (scripts, snippets, etc.) pertaining to the application should be placed within the same folder the relevant application is using.


## Build locally

- Install Docker and Docker Compose:
    - Windows 10: [Docker](https://docs.docker.com/docker-for-windows/install/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-windows-desktop-systems)
    - MacOS: [Docker](https://docs.docker.com/docker-for-mac/install/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-macos)
    - CentOS: [Docker](https://docs.docker.com/install/linux/docker-ce/centos/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems)
    - Debian: [Docker](https://docs.docker.com/install/linux/docker-ce/debian/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems)
    - Fedora: [Docker](https://docs.docker.com/install/linux/docker-ce/fedora/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems)
    - Ubuntu: [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/), [Docker Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems)

- Clone the repository and `cd` into the directory:

```bash
git clone https://github.com/selfhostedshow/wiki wiki &&\
	cd wiki
```

- Start development server on http://localhost:8000:

```bash
docker-compose up
```

- In your browser go to http://localhost:8000.


## How to Contribute

Please at least try to understand the objectives of this wiki and the organizational layout of the repository before attempting to contribute.

This Wiki is intended to be for _anyone_ -- regardless of expertise -- who is interested in self-hosting. We encourage anyone interested in contributing to follow these simple steps:

- Fork this repository in Github's web interface by pressing the fork icon.
- Clone your fork and `cd` into the new directory: `git clone https://github.com/username/wiki && cd wiki`
- Check out the "dev" branch: `git checkout -b dev`
- Make changes as desired to the files in the repository on your machine.
- Add the changed files to your commit and commit the changes to your fork: `git add file1.md file2.md && git commit -m 'updated x,y,z'`
- Push your commit to your fork: `git push origin dev`
- [Build the wiki locally](https://github.com/selfhostedshow/wiki/blob/master/CONTRIBUTING.md#build-locally) and check that your added content renders properly in your local build.
- On Github's web interface go to your fork and set the branch to "dev". Then submit a pull request by selecting "New Pull Request".

Not sure what to write about, take a look at our [issues](https://github.com/selfhostedshow/wiki/issues).

## Other Resources

For help with Markdown:

[Markdown -- Github Help](https://help.github.com/en/github/writing-on-github)

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
