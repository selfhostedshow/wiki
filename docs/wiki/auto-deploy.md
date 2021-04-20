# Auto Deploy

To streamline the merging and deployment process, this wiki automatically deploys upon merge to `master`.

In future, we're hoping to add preview environments for each PR.

__Note__: This process isn't live, yet.

## How does it work?

Here's how the autodeploy works:

### 1. PR is merged

After a successful code review, the PR is merged. On merge, a GitHub Actions workflow starts.

### 2. Build Site

The workflow builds the exact same container as in local development, so the output build is exactly the same. Unlike local development, this doesn't spin up a development server, instead it saves the site to the filesystem of the production server ready for use later on.

### 3. Build Production Container

The development server which comes with `mkdocs` isn't suited, nor suitable, for a production environment. For this, we build a custom container based off [NGINX](https://hub.docker.com/_/nginx/), which is far better suited, and allows for more control over the server. This container is built locally on the production server and is not pushed to any registry. 

### 4. Container Update and Prune

Once the build of the production custom container is complete it is started on the server using `docker-compose`. Within the same step the old image is pruned. This is done automatically as quickly as possible, to minimise potential downtime during the switchover. [`nginx.conf`](https://github.com/selfhostedshow/wiki/blob/master/prod/nginx.conf) utilizes the filesystem output of step 2 for the wiki content.

## Configuration

The configuration for all this is available on [GitHub](https://github.com/selfhostedshow/).

Some notable files:

- [GitHub Actions deploy workflow](https://github.com/selfhostedshow/wiki/blob/master/.github/workflows/deploy.yml)
- Production [Dockerfile](https://github.com/selfhostedshow/wiki/blob/master/prod/Dockerfile) and [`nginx.conf`](https://github.com/selfhostedshow/wiki/blob/master/prod/nginx.conf)
- wiki [`docker-compose.yml`](https://github.com/selfhostedshow/wiki/blob/master/docker-compose.yml)
