# selfhostedshow/wiki

This repository contains the backend for the [Self-Hosted](https://selfhosted.show) podcast wiki.

## Usage

Add the following line to your mkdocs.yml:

    theme:
      name: 'material'

Mount the folder where your mkdocs.yml resides as a volume into /docs:

* Start development server on http://localhost:8000
  
    `docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material`

* Build documentation

    `docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material build`

* Deploy documentation to GitHub Pages (don't do this in docker)

    `mkdocs gh-deploy --clean`

For detailed installation instructions and a demo, visit http://squidfunk.github.io/mkdocs-material/