# Contributing to the Self Hosted Show Wiki


## Objectives of This Wiki

In order to contribute well, you need to understand what the objectives are behind this wiki.

What we are trying to create:
- A compilation of tools, tips and tricks for self-hosting specific applications.
- A place where beginners and experts can learn about how to quickly, efficiently and securely deploy applications on their own server(s).
- Snippets that people can quickly reference in deploying applications.
- A hub for quality documentation (to the extent possible).

What we are not trying to do:
- Be another large list of self-hosted tools. See [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) for a comprehensive list of self-hosted applications.
- Be a hub for script kitties. People should _learn_ from documentation here not just come here to copy/paste. Snippets are important but should be documented properly.


We want to encourage the use of dev/ops tools such as Docker, Ansible, SALT Stack, etc. for increased ease of use and for automating/standardizing as much as possible.


## Directory Layout:

The `docs` folder in the root of the repository is where wiki content should be placed.

The following example directory layout should be adhered to when contributing:

`docs/category/application/application.md`


For example, if I wanted to add an article for Home Assistant, my layout could be this:

`docs/home-automation/home-assistant/home-assistant.md`

This would assume that the `home-assistant.md` entry belongs in the `home-automation` category. Look at the existing category directories before attempting to create a completely new category directory.


Any images embedded in an article should be placed within a folder called `images` within the same directory:

`docs/home-automation/home-assistant/images/example.png`


Any other relevant resources (scripts, compose files, Ansible playbooks, etc.) pertaining to the application should be placed within the same folder the relevant application is using.


## Directory Layout:

The `docs` folder in the root of the repository is where wiki content should be placed.

The following example directory layout should be adhered to when contributing:

`docs/category/application.md`


For example, if I wanted to add an article for Home Assistant, my layout could be this:

`docs/home-automation/home-assistant.md`

This would assume that the `home-assistant.md` entry belongs in the `home-automation` category. Look at the existing category directories before attempting to create a completely new category directory.




## How to Contribute

Please at least try to understand the objectives of this wiki and the organizational layout of the repository before attempting to contribute. 

This Wiki is intended to be for _anyone_ -- regardless of expertise -- who is interested in self-hosting. We encourage anyone interested in contributing to follow these simple steps:

- Fork this repository.
- Make changes as desired to the code in the repository and commit them to your fork.
- Follow the build instructions in [BUILD.md](BUILD.md). Check that your added content renders properly in your local build.
- Submit a pull request. The more detail the better in your comments with your pull request.


## Other Resources

For help with Markdown:

[Markdown -- Github Help](https://help.github.com/en/github/writing-on-github)

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
