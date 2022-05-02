# Auto Deploy

To streamline the merging and deployment process, this wiki automatically deploys upon merge to `master`.

In future, we're hoping to add preview environments for each PR.

__Note__: This process isn't live, yet.

## How does it work?

Here's how the autodeploy works:

### 1. PR is merged

After a successful code review, the PR is merged. On merge, a GitHub Actions workflow starts.

### 2. Download to Production Server

The workflow downloads the project to the production server using `git fetch`, `git checkout` and `git pull`.

### 3. Build Site

The workflow builds the exact same container as in local development, so the output build is exactly the same. Unlike local development, this doesn't spin up a development server, instead it saves the site to the filesystem.

!!! note "Production vs Development"
    The development server which comes with `mkdocs` isn't suited, nor suitable, for a production environment. For this, we build a custom container based off [NGINX](https://hub.docker.com/_/nginx/), which is far better suited, and allows for more control over the server. This container is built locally on the production server and is not pushed to any registry. 

### 4. Restarting Container and Prune

Once the build of the site is complete the custom container (please see the note below) is started on the server using `docker-compose`. Within the same step old images are pruned. This is done automatically as quickly as possible, to minimize potential downtime during the switchover.

## Configuration

The configuration for all this is available on [GitHub](https://github.com/selfhostedshow/).

Some notable files:

- [GitHub Actions deploy workflow](https://github.com/selfhostedshow/wiki/blob/master/.github/workflows/deploy.yml)
- wiki [`docker-compose.yml`](https://github.com/selfhostedshow/infra/blob/master/ansible/group_vars/demo.yaml#L133)
