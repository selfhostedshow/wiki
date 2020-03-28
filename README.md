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

The site will then be output into the `site/` directory
