# Why DNS?

DNS introduces some additional complexity to your self hosted systems, so why bother?
Here we discuss what DNS related features can be used and why you might (or might not) want them.

DNS related features include, in rough order of complexity to configure:

* Quickly find local servers with multicast DNS (i.e. Avahi, Bonjour, NetBIOS)
* Faster web browsing with local caching (e.g. unbound)
* Content blocking on your whole network (e.g. pi-hole)
* Access self hosted services with custom names (i.e. typical web usage)
* Access self hosted servers that have multiple IP addresses (e.g. IPv4 and IPv6 dual stack)
* Access self hosted servers with changing IP addresses (e.g. your home public IP)
* Access self hosted https websites with certbot (i.e. typical web usage)
* Verify your custom DNS records (i.e. DNSSEC)
* Verify self hosted SSH server keys (i.e. SSHFP records)

## Multicast DNS

> As networked devices become smaller, more portable, and more ubiquitous, the ability to operate with less configured infrastructure is increasingly important.  In particular, the ability to look up DNS resource record data types (including, but not limited to, host names) in the absence of a conventional managed DNS server is useful.
>
>https://www.rfc-editor.org/rfc/rfc6762

Multicast DNS (mDNS) essentially works by letting each device announce itself to the network.
These announcements will eventually be sent to every device on the network.
You can look for all the mDNS devices on your network with the avahi-browse tool like

```
> avahi-browse -a -l -r
...
= enp5s0 IPv4 nas                                       _smb._tcp            local
   hostname = [nas.local]
   address = [198.51.100.2]
   port = [445]
   txt = []
...
```

where we can see announcements from the host nas.local that has IP address 198.51.100.2.
Since Avahi/Bonjour also does service discovery, this corresponds to a service (smb on port 445 which enables browsing the samba shares on most files apps).

<details>
<summary>🤓 tangent</summary>
Advertising services can also be the job of a directory server. mDNS simplifies this experience greatly - homeassistant auto detection of ESPHome devices being a great example.
</details>

The promise of mDNS is a simple user experience where you type "nas.local" into your browser and get going.
This is especially useful for local (trusted) connections like webservers (e.g. homeassistant), network shares on desktop (e.g. samba shares), airplay devices on iOS, and more.

For some setups, it may be possible that mDNS is enough for your self-hosting needs.
Since mDNS can coexist with traditional DNS, it is an excellent way to get started quickly with self-hosted (local) services.

<details>
<summary>🚩 approval factor warning</summary>
Most web browsers issue a subtle warning when using http://myserver.local web sites as will be expected with mDNS web sites, but still function as normal.
Friends and family may not notice, or this may not be an issue at all if using an app (like home assistant) or services (like samba).

Trying to enable https://myserver.local with a self signed certificate may prevent your users from accessing the site.
Getting a valid certificate with certbot requires obtaining a domain name, which is not possible through mDNS alone.
</details>

<details>
<summary>⚠️ technical limitation</summary>
mDNS only works on a single subnet.
If you want to advertise services on multiple subnets you will need a IGMP proxy, which increases the complexity and contradicts the zero configuration promise of mDNS.
</details>

## Local caching DNS server

Resolving domain names is a huge part of browsing the web: the first thing that has to happen is a DNS look up before the web page even starts loading.
Many sites will also need name resolution for components of the web page: content servers, ad servers, and more.
Fast name resolutions often means faster page load times (although, it won't speed up large file downloads like movies or video games).

Perhaps the easiest way to get faster internet speeds on your network is to set [Cloudflare's 1.1.1.1](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) as your default DNS server on your router (e.g. [LTT video](https://youtu.be/kqnvrjgyEMc)).
This can be done on the majority of home routers, even the ones provided by your ISP. Cloudflare boasts fast name resolutions speeds at around 15 ms.
On a test machine, resolving google.com with their server takes...

```
> dig @1.1.1.1 google.com
...
;; Query time: 16 msec
;; SERVER: 1.1.1.1#53(1.1.1.1) (UDP)
...
```

about 15 ms as advertised. But this is not self-hosted.

Installing a local caching server can reduce the time it takes to resolve names, and accordingly reduce the time it takes to start loading web pages.
Local caching servers like [Unbound](https://www.redhat.com/sysadmin/bound-dns) and [Dnsmasq](https://dnsmasq.org/) can greatly decrease that time.

Self-hosting a caching DNS server can have various levels of complexity depending on what equipment you already own: router/firewall appliances like [pfSense](https://www.pfsense.org/) and [OPNsense](https://opnsense.org/) can enable this feature in just a few clicks, home servers like [homeassistant](https://www.home-assistant.io/) can similarly enable caching but you will have to configure it as the default DNS in your router, ad blocking appliances like [Pi-hole](https://pi-hole.net/) and [AdGaurdHome](https://github.com/AdguardTeam/AdguardHome) have caching built in.
You most likely do not need to buy any additional hardware, even a raspberry pi zero will do.

The advantage of a local caching server is easily verified. On a test machine, resolving google.com with a local server takes...

```
> dig @198.51.100.1 google.com
...
;; Query time: 3 msec
;; SERVER: 198.51.100.1#53(198.51.100.1) (UDP)
...
```

3 ms, a 5 fold reduction! While these gains may seem small, they will likely improve the web browsing experience and can make a low cost starting project in self-hosting.

<details>
<summary>🚩 approval factor warning</summary>
For family and friends, a DNS outage is equivalent to an internet outage.
While self-hosting a local caching service can bring speed improvements, providing a fallback dns like 1.1.1.1 or 9.9.9.9 (or both) can increase reliability.
</details>

## Content Blocking with DNS

Given that advertisements are a ubiquitous part of the internet, wanting to block them on as many devices as possible is a common goal.
Families with young children may want to block malware or adult content on their network.
Web browser add ons like uBlock work really well, but if you use a device like a ChromeCast, AppleTV, or NvidiaShield there may not be any add blocking apps available.

DNS content blockers attempt to identify unwanted domains (e.g. ads, malware, adult content) and replace their IP address with a "black hole" that emulates ad server failure, e.g. serving a single black pixel.
This works well for third party advertising services that serve only ads from their domain.
If the content server and the advertising server are the same, e.g. youtube, then you cannot block ads this way without also blocking the content.

<details>
<summary>🤓 tangent</summary>
Replacing an authentic DNS record (e.g. the one from the ad company) with another private IP address is sometimes called a DNS rebinding attack and can be used to deliver viruses.
This can be prevented by a simple check on the client (and is enabled by default on pfSense and OPNsense) or with DNSSEC.
As a result, this method may not work for all clients, even if you can identify an ad only domain.
</details>

Some DNS providers offer this feature to block malware and adult content, e.g. [Cloudflare for families](https://developers.cloudflare.com/1.1.1.1/setup/). But this is not self-hosted.

Implementing this on your network work usually requires setting up the server and pointing your network DNS to it.
Follow the guide for your preferred appliance, for example:

* [Pi-hole](https://pi-hole.net/)
* [AdGaurdHome](https://github.com/AdguardTeam/AdguardHome)
* [pfBlockerNG](http://pfblockerng.com/)

<details>
<summary>🚩 approval factor warning</summary>
Blocking ads is great, and your friends and family are likely to excuse a few false negatives (i.e. missed ads).

However, false positives (i.e. blocking content they would like to see) will result in complaints about the internet being broken.
</details>

## Authoritative DNS

Authoritative DNS is when you control a unique domain name, e.g. google.com is controlled by the company Google LLC.
Domains (that you can purchase) are granted by top-level domains (such as .com or .xyz) and records within that domain (e.g. www.google.com) are controlled by you.
These records can be used to identify servers and distribute information.

### Registering

You can purchase a domain from a variety of registrars like namecheap, among many others.
Pricing and other related features (like web hosting, email, etc.) vary among them, but you pay a small annual fee (\$1 to \$75) for control of the domain.

<details>
<summary>⚠️ privacy warning</summary>
Domain ownership is registered in a WHOIS database.
Since (at least when the internet was first started) they are typically purchased by businesses with a public address and contact info, the WHOIS information can also public.
Make sure to enable the domain privacy service with your registrar.

For example, a whois lookup of google.com

```
> whois google.com
...
Registrant Organization: Google LLC
Registrant State/Province: CA
Registrant Country: US
...
```

and a lookup of selfhosted.show shows a redacted whois

```
> whois selfhosted.show
...
Registrant Organization: Privacy service provided by Withheld for Privacy ehf
Registrant State/Province: Capital Region
Registrant City: REDACTED FOR PRIVACY
Registrant Street: REDACTED FOR PRIVACY
...
```

A great feature since you most likely do not want your address posted along side your domain.
</details>

### Adding records

Self hosted authoritative DNS may be achieved with BIND, however it can be complex to setup - checkout the guide on this wiki for more details.
Many companies offer authoritative DNS as at least part of their services (e.g. cloudflare, amazon, and many more) with a simplified interface.
Refer to their docs to get going.

If your self hosted applications are in the cloud, your cloud provider may integrate DNS features with their other services.
For example, Linode can update DNS records when you deploy a one-click app.

To avoid lock in with any single provider, using a domain management tool like octodns or dnscontrol will let you define your hosts from a single configuration file and distribute those records to your DNS servers of choice (including a self hosted BIND server).
These tools can also update multiple servers at once (e.g. to test out a new service).

Using octodns, these records are in yaml and look something like

```
nas:
  - type: A
    value: 198.51.100.2
  - type: AAAA
    value: 2001:db8::1
```

and the changes to the yaml file can be synced to all the providers in your configuration file simultaneously.

If you use git for version control, reverting a change is as simple as reverting to a previous commit and re-syncing.
These tools are compatible with a CI/CD pipeline, for advanced configurations.

<details>
<summary>🚩 approval factor warning</summary>
For friends and family, DNS outages are internet outages.
If your late night experimentation has a breaking change, having the ability to quickly roll back can be helpful.
</details>

### Dynamic records

If you want to automatically update the record of a changing IP address (e.g. your home IP may change regularly), then a dynamic DNS service can be used to continuously update those records.
Most DNS providers have tools built explicitly for this.

In the particular case of changing home IP (perhaps the most common for self hosting), integrating this with your firewall is especially convenient since it is always knows when it gets a new IP from your ISP.
On appliances like pfSense and OPNsense this is configurable in the web gui.
Other devices can still do this, however, as long as they have access to the IP - [Davide Gironi's blog](https://davidegironi.blogspot.com/2017/02/duck-dns-esp8266-mini-wifi-client.html) demonstrates how to with just an ESP8266.

### Certbot on private servers

The default way to get a valid https certificate is for certbot to check port 80 on the servers host name - this proves that you have control over the server and domain before they distribute a certificate.
If you don't want to make your server available from the internet, then this will not work as you do not intend to open port 80 to the world.

An alternate method is with DNS validation which requires you to change the DNS records in response to a challenge.
This allows certbot to validate your ownership of the domain, even behind a firewall.
Many dns providers integrate with certbot and are [available on pypi](https://pypi.org/search/?q=certbot-dns&o=).

## Secure DNS

DNS is public information so securing it may not seem necessary, but as discussed in the content blocking section, it is possible for servers to change DNS records before delivering them to clients.
DNSSEC is a way of verifying that the DNS record you have is the same as the one provided by the authoritative server.
Enabling this with your provider may be as simple as checking a box and adding a DNSKEY record to your registrar, but follow your providers instructions for more details.


Once enabled your DNS lookups will have the "ad" flag, e.g.

```
> dig cloudflare.com
...
;; ->>HEADER<<- opcode: QUERY, status: NOERROR
;; flags: qr rd ra ad;
...
```

whereas a record that doesn't match will SERVFAIL, e.g.

```
> dig dnssec-failed.org 
...
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL
;; flags: qr rd ra;
...
```

checkout [DNSSEC Mastery](https://mwl.io/nonfiction/networking#dnssec2e) for more details.

### SSHFP records

DNSSEC is a security feature so most likely it is enabled for securities sake, but it does have at least one usable feature in a self hosted environment: ssh host verification.

When you SSH into a server for the first time (something you're likely used to if you're reading this), ssh will ask you to verify that the key fingerprint is what you expected, like:

```
> ssh nas.local                     
The authenticity of host 'nas.local (198.51.100.2)' can't be established.
ED25519 key fingerprint is SHA256:asdfghjkl;zxcvbnmqwertyuiop1234567890asdfjk.
No matching host key fingerprint found in DNS.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? 
```

then you type yes and connect.
This adds nas.local to your `~/.ssh/known_hosts` file and will not ask you again until it is removed or if the keys on that host change, in which case it will refuse to connect and show a big security warning.
It's possible (like me) you've never actually compared those fingerprints to the one on your host.

SSHFP records distribute those fingerprints so that the comparison is automated.
This means that the prompt is not given on first connection.
If the ssh keys are changed on the host (e.g. with ssh-keygen -A or by rolling out new hardware) then, as long as the SSHFP records are updated, the security warning will not show and there is no need to edit `~/.ssh/known_hosts` on all of your workstations.