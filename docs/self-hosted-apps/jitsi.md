## What is Jitsi
View Jitsi's full docs [here](https://jitsi.github.io/handbook/docs/intro)

Jitsi is a video conferencing suite - video server, client, video stream negotiator, media session manager, SIP gateway, and stream/recording manager. This gives the ability to run your own Zoom-like/Google Meet-like/Teams-like meeting with hardware at home.

## Getting started
Because of its agnostic nature, this guide recommends using the [Docker container guide](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker). However, as seen on that page there are other methods of installing: [Debian/Ubuntu](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-quickstart) and [Manual](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-manual). Use whichever deployment you're comfortable with for your environment.

The quickstart guide linked above will essentially give a proof-of-concept Jitsi install on the LAN. To make the Jitsi server public, you need a domain name, ports 80/tcp, 443/tcp and 10000/udp forwarded to the host, and the settings below.

!!!attention "Make sure to read the official docs"
    Always read the source docs, do not rely directly on this page. This is an overview, and should be treated as such.

### Requirements (checked 2026-11)
- [Docker engine](https://docs.docker.com/engine/install/) with the [Compose plugin](https://docs.docker.com/compose/install/) (`docker compose`, not the old `docker-compose`)
- [Openssl](https://github.com/openssl/openssl#download) (used by `gen-passwords.sh`)

### Install from the latest release
Follow the [Docker guide](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker): download and unzip the latest stable release, copy `env.example` to `.env`, run `./gen-passwords.sh`, create the config folders under `~/.jitsi-meet-cfg` as shown there, then `docker compose up -d`.

### Reconfigure for a public server
It is recommended to set all configurations _before_ enabling Let's Encrypt. This will allow a public test of the server, and ensure port forwarding or reverse proxy is set up correctly. Ensure you have a public DNS record for your domain:

- Shut down the containers: `docker compose down` (may need to use sudo)
- Edit the `.env` file: set `PUBLIC_URL` to your domain and `JVB_ADVERTISE_IPS` to the server's public IP. If calls work with two people but audio and video drop when a third joins, UDP 10000 or this setting is almost always the cause.
- Remove then recreate the config directory so the new settings are applied, using the `mkdir` commands from the Docker guide (the folder list changes between releases).
- Test connection via a browser to ensure DNS, routing, and any specific `.env` settings are working as predicted. You will likely still run into an HTTPS error, however the website and meeting tools should work on a desktop browser.

### Let's Encrypt
Let's Encrypt support is built into the web container. In `.env` set:

- `ENABLE_LETSENCRYPT=1`
- `LETSENCRYPT_DOMAIN=meet.example.com`
- `LETSENCRYPT_EMAIL=you@example.com`
- `HTTP_PORT=80` and `HTTPS_PORT=443` (the defaults are 8000 and 8443)

While testing, `LETSENCRYPT_USE_STAGING=1` avoids the rate limits. Note from `env.example`: with Let's Encrypt enabled, a JaaS account is created automatically using `LETSENCRYPT_EMAIL`. Then run `docker compose down && docker compose up -d`.

Congrats on creating your Jitsi meet server!

### Further reading
- [Official Docker guide](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker)
- [Self-host Jitsi Meet with JWT auth and Jibri recording](https://www.rakibulinux.com/blogs/jitsi-meet-docker-jwt-jibri-setup), a walkthrough that adds login tokens, recording, Etherpad and phone dial-in on top of the steps above
