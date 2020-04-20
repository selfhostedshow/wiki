# Auto Deploy

To streamline the merging and deployment process, this wiki automatically deploys upon merge to `master`.

In future, we're hoping to add preview environments for each PR.

__Note__: This process isn't live, yet.

## How does it work?

Here's how the autodeploy works:

### 1. PR is merged

After a successful code review, the PR is merged. On merge, a GitHub Actions workflow starts.

### 2. Build Site

The workflow builds the exact same container as in local development, so the output build is exactly the same. Unlike local development, this doesn't spin up a development server, instead it saves the site to the filesystem.

### 3. Build Production Container

The development server which comes with `mkdocs` isn't suited, nor suitable, for a production environment. For this, we build a custom container based off [NGINX](https://hub.docker.com/_/nginx/), which is far better suited, and allows for more control over the server.

### 4. Publish Container

Once the production container is built, it's pushed to GitHub's [container registry](https://github.com/selfhostedshow/infrastructure/packages).

### 5. Server Pull

Every 30 seconds, the server polls GitHub's container registry for new containers, using [watchtower](https://containrrr.github.io/watchtower/). When a new container is pulled, it's

### 6. Restart

Once the new container is pulled, watchtower stops the running container, and replaces it with the new one. This is done automatically as quickly as possible, to minimise potential downtime during the switchover.

## Configuration

The configuration for all this is available on [GitHub](https://github.com/selfhostedshow/).

Some notable files:

- [GitHub Actions deploy workflow](https://github.com/selfhostedshow/wiki/blob/dev/.github/workflows/deploy.yml)
- Production [Dockerfile](https://github.com/selfhostedshow/wiki/blob/dev/prod/Dockerfile) and [`nginx.conf`](https://github.com/selfhostedshow/wiki/blob/dev/prod/nginx.conf)
- watchtower [`docker-compose.yml`](https://github.com/selfhostedshow/infrastructure/blob/master/ansible/roles/watchtower/files/docker-compose.yml)
- wiki [`docker-compose.yml`](https://github.com/selfhostedshow/infrastructure/blob/master/ansible/roles/wiki/files/docker-compose.yml)
