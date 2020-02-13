## Build locally

Mount the folder where your mkdocs.yml resides as a volume into /docs:

* Start development server on http://localhost:8000

    `docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material`
