[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/selfhostedshow/wiki)

# selfhostedshow/wiki

![CI Status Badge](https://github.com/selfhostedshow/wiki/workflows/Test/badge.svg)

This repository contains the backend for the [Self-Hosted](https://selfhosted.show) podcast wiki.

## Usage

### Start development server

`docker-compose up`

Then open your browser to http://localhost:8000

### Build documentation

Sometimes, you just want to output the HTML into a directory, rather than use the development server.

`docker-compose run wiki build`

The site will then be output into the `site/` directory.

### Contribution Template

The file `contribution-template.md` has been provided as a sample and possible starting point. It is located along with this `README` file. Feel free to copy and use this template.

The file `canonocal-template.md` has been provided as a sample and possible starting point if you wish to cross-post an article from your own blog. It is located along with this `README` file. Feel free to copy and use this template.
