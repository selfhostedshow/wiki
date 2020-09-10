## What is Jitsi
As [Jitsi](https://jitsi.github.io/handbook/docs/intro)'s website states:

!!!quote "What is Jitsi?"
    Jitsi is a collection of Open Source projects which provide state-of-the-art video conferencing capabilities that are secure, easy to use and easy to self-host.

In other words, Jitsi is a video conferencing suite - video server, client, video stream negotiator, media session manager, SIP gateway, and stream/recording manager. This gives the ability to run your own Zoom-like/Google Meet-like/Teams-like meeting with hardware at home.

## Getting started
Because of its agnostic nature, this guide recommends using the [Docker container guide](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker). However, as seen on that page there are other methods of installing: [Debian/Ubuntu](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-quickstart) and [Manual](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-manual). Use whichever deployment you're comfortable with for your environment.

The quickstart guide linked above will essentially give a proof-of-concept Jitsi install on the LAN. In order to publicize the Jitsi server, 

!!!attention "Make sure to read the official docs"
    Always read the source docs, do not rely directly on this page. This is an overview, and should be treated as such.

### Requirements as of 2020-09-05
- [Docker engine](https://docs.docker.com/engine/install/) (aka "docker")
- [Docker-compose](https://docs.docker.com/compose/install/)
- Git
- Openssl

## Public Jitsi server
Once the quickstart guide is completed, the existing setup can be used to set up a public Jitsi server. Follow the [Let's Encrypt](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker#lets-encrypt-configuration) guide to allow for the mobile app.

### Reconfigure quickstart config for public server
It is recommended to set all configurations _before_ enabling Let's Encrypt. This will allow a public test of the server, and ensure port forwarding or reverse proxy is set up correctly. Ensure you have a public DNS record for your domain:

- Shut down the quickstart docker images: `docker-compose down` (may need to use sudo)
- Edit `.env` file to match public domain, IP, etc.
- Remove then recreate the config directory: `rm -r ~/.jitsi-meet-cfg && mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}`
- Test connection via a browser to ensure DNS, routing, and any specific `.env` settings are working as predicted. You will likely still run into an HTTPS error, however.

### Prepare meet.example.com for a TLS certificate
In order for the mobile app to work with the self-hosted Jitsi server and for the https error to be removed the web server will need to be issued a TLS certificate.

- Edit the `.env` file and follow the instructions above to recreate the config directory, then bring the containers back up.
- Use `docker exec` to connect to the web container, eg: `docker exec -it docker-jitsi-meet_web_1 bash`.
- Recommended: Install `certbot` using the Debian-based [instructions](https://certbot.eff.org/lets-encrypt/debianstretch-nginx) (snapd seems like a nice alterative, but will be a more difficult way to get set up within the container).

### Extra tips
- The web server uses nginx
