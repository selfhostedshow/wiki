---
title: Self Hosting a Caching / Authoritative Internal DNS Sever.
summary: Something
date: 2020-11-26
authors:
  - Adam Spann
---
# Self Hosting a Caching / Authoritative Internal DNS Sever.

## What is DNS?

DNS (Domain Name Services) is a distributed approach to mapping hosts/domains to IP address.
The traditional analogy is the classic, long forgotten, phone book. You know your friend's name (host/domain), but it's hard to remember phone numbers (IP Address). DNS solves that issue. It also distributes the information and management.

## Why you might want or need DNS?

Sometimes our internal/home networks become large and complex. Editing local host files on each and every machine can start to take more time, and we might forget to update a single machine. A good solution would be to centralise this information. Enter DNS.

## The guides:
### [Debian 9.13 (Stretch)](debian-stretch.md)

# References:
- [Split Horizon Master/Slave](https://jensd.be/160/linux/split-horizon-dns-masterslave-with-bind)
- [Digital Ocean DNS Configuration](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-debian-9)
