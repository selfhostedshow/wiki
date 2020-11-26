---
title: Debian 9.13 (Stretch) DNS Configuration.
summary:
date: 2020-11-26
authors:
  - Adam Spann
---
## Installation
```
  apt update && apt upgrade
  apt install bind9 dnsutils
```
This will update the server so that we have the latest patched modules and libraries and then install Bind9.

## Configuration.

### Some Assumptions.
Whilst assumptions are the mother of all hiccups. I will make a few.

- You have not set up Bind previously.
- Your network address space is 192.168.11.0/24
- You have chosen two servers for your DNS services.
  - 192.168.11.10 (Primary)
  - 192.168.11.20 (Secondary)
- Please change these in your setting to match your own network.

### Usful Tools and Commands:
- dig
- nslookup (alternative to dig)
- named-checkconf
- named-checkzone
- systemd-resolve --status

### Important files
```
  /etc/default/bind9
  /etc/bind/*
```
**/etc/default/bind9**
```
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind"

```

This file is where we can set additional options which are passed to bind on startup. We can specify if our network is IP4 only and if we want to run the service chrooted. I will not go into that here. I am assuming that the DNS server will only be used internally behind a NAT router and not exposed to the internet. Thus additional security is not required.

### /etc/bind/

!!! note "named.conf"
    This is the main configuration file.

    We can break this into multiple files which can be included in **named.conf** by using the **include** directive.

#### Working with configuration files.

Let's start by creating a file that will contain our ACLs (Access Control List) and add the following contents.

```
cd /etc/bind/
```

##### named.conf.acl

Create a file called **named.conf.acl**

Then add the following contents.


```
acl "internal" {
	192.168.11.0/24; # Local Area Network.
	127.0.0.1; # Localhost
};

```

This will be used to allow DNS to make external lookups for the address ranges specified. This is very important if your DNS server is exposed on the internet. Not really needed if it is not exposed. But let's follow some best practices.

##### named.conf

Next we want to add this to our **named.conf** file.
Let's add this to the top of the file.

```
include "/etc/bind/named.conf.acl";
```

**named.conf** will now load this information as part of its configuration.

The **named.conf** file should now look something like this:
```
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian.gz for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.acl";

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
```
There is no more work to be done with the **named.conf** file. So we will not be looking at it again. You can and probably should check that the configuration file has no problems by using this command.

```
named-checkconf
```
This will report errors and their line numbers if they exist.

##### named.conf.options

**named.conf.options**

Let's turn to the options file.
The default version will look something like this:

```
options {
	directory "/var/cache/bind";

	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable
	// nameservers, you probably want to use them as forwarders.
	// Uncomment the following block, and insert the addresses replacing
	// the all-0s placeholder.

	// forwarders {
	// 	0.0.0.0;
	// };
...
...
};
```


Lets add some options just below the **directory** option:

```
    recursion yes;
    allow-recursion { internal; };
    listen-on { 127.0.0.1; 192.168.11.10; };
    allow-transfer { none; };
```

**What do these options mean?**

1. Enable recursion so that the server can make lookups for us.
2. Limit the addresses that can do recursive lookups to the addresses we specified using the **internal** ACL. A pretty standard security measure.
3. Listen for and answer DNS queries that come in. Limited to the internal loopback address and the main interface address. If you do not want to restrict the listen-on interfaces, use a value of **any;**. The use of **any** is not recommended. And should certainly not be used if any of your interfaces are internet facing!
4. Don't allow zone transfers to secondary DNS servers. This can and will be adjust on a zone by zone basis later if you configure a secondary name server for your network.

Next look at the **forwarder** portion. This is were we can tell the DNS server who it should go and ask to make lookups on its behalf if it doesn't already know the answer. Either because it is not the authoritative server or does not have a cache record. This would generally be your ISP's name servers. But you are free to use others. Such as **8.8.8.8** and other public DNS servers. Though using a name server that is not local or part of your normal service is generally frowned upon and could also result in slow lookups.

The primary benefit of using forwarders is that hopefully someone else has already made the same DNS lookup using that server. The server will probably therefore already have a cached answer. This results in a faster lookup. Though it is not required for operations as the name server is able to query the root servers. Though this is going the long way around when a cached answer is probably only a single server away.

Let's remove the **//** characters which are comment markers and add some addresses.

```
    forwarders {
      8.8.8.8;
      x.x.x.x;
    };

```

Save the file and again use the **named-checkconf** command to make sure no errors have been introduced.

!!! warning
    You might hit an issue during testing. You might find that lookups work without any forwarders set, but fail with them set.

    If you want to use forwarders. The work around here is as follows:

    **Reference:** [ServerFault Link](https://serverfault.com/questions/429757/bind9-forwarders-are-not-working)

    Update the **dnssec-validation** line.

    Replace **auto** with **no**

    The other option is to not use forwarders and let your server query the root name servers as needed.

At this point you basically have a caching server configuration. It might be a good idea to test that it's working. Let's start bind.

```
systemctl enable bind9
ststemctl start bind9
```

At the moment the server itself doesn't know to use the newly configured bind service. But we can cheat here. And actually this is useful trick when you are testing DNS related issues.
We can use the **dig** command.

```
dig www.google.com @localhost

```
!!! note "Using @"
    The **@localhost** is saying we want to specifically send our DNS query to the localhost without using the **/etc/resolv.conf** file.

Which should give you output similar to the text below. This will probably be a little different on your own system.
```
; <<>> DiG 9.10.3-P4-Raspbian <<>> www.google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18246
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 13, ADDITIONAL: 27

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.google.com.			IN	A

;; ANSWER SECTION:
www.google.com.		86	IN	A	172.217.24.132

;; AUTHORITY SECTION:
.			411182	IN	NS	b.root-servers.net.
.			411182	IN	NS	h.root-servers.net.
.			411182	IN	NS	g.root-servers.net.
.			411182	IN	NS	l.root-servers.net.
.			411182	IN	NS	j.root-servers.net.
.			411182	IN	NS	f.root-servers.net.
.			411182	IN	NS	e.root-servers.net.
.			411182	IN	NS	k.root-servers.net.
.			411182	IN	NS	a.root-servers.net.
.			411182	IN	NS	i.root-servers.net.
.			411182	IN	NS	d.root-servers.net.
.			411182	IN	NS	m.root-servers.net.
.			411182	IN	NS	c.root-servers.net.

;; ADDITIONAL SECTION:
a.root-servers.net.	335582	IN	A	198.41.0.4
a.root-servers.net.	335424	IN	AAAA	2001:503:ba3e::2:30
b.root-servers.net.	336203	IN	A	199.9.14.201
b.root-servers.net.	335567	IN	AAAA	2001:500:200::b
c.root-servers.net.	335601	IN	A	192.33.4.12
c.root-servers.net.	335299	IN	AAAA	2001:500:2::c
d.root-servers.net.	343081	IN	A	199.7.91.13
d.root-servers.net.	343973	IN	AAAA	2001:500:2d::d
e.root-servers.net.	336987	IN	A	192.203.230.10
e.root-servers.net.	336987	IN	AAAA	2001:500:a8::e
f.root-servers.net.	335460	IN	A	192.5.5.241
f.root-servers.net.	335895	IN	AAAA	2001:500:2f::f
g.root-servers.net.	336203	IN	A	192.112.36.4
g.root-servers.net.	335863	IN	AAAA	2001:500:12::d0d
h.root-servers.net.	335567	IN	A	198.97.190.53
h.root-servers.net.	335785	IN	AAAA	2001:500:1::53
i.root-servers.net.	335363	IN	A	192.36.148.17
i.root-servers.net.	335424	IN	AAAA	2001:7fe::53
j.root-servers.net.	335298	IN	A	192.58.128.30
j.root-servers.net.	335785	IN	AAAA	2001:503:c27::2:30
k.root-servers.net.	335460	IN	A	193.0.14.129
k.root-servers.net.	335567	IN	AAAA	2001:7fd::1
l.root-servers.net.	335601	IN	A	199.7.83.42
l.root-servers.net.	335443	IN	AAAA	2001:500:9f::42
m.root-servers.net.	343973	IN	A	202.12.27.33
m.root-servers.net.	343835	IN	AAAA	2001:dc3::35

;; Query time: 33 msec
;; SERVER: ::1#53(::1)
;; WHEN: Sat Nov 21 23:37:26 JST 2020
;; MSG SIZE  rcvd: 842
```

Now we have a working caching name server. Time to make the server use it for its own DNS lookups.

### Modifying /etc/resolv.conf
There seems to be a few ways to do this.

1. Edit the file manually. An acceptable option if you are setting your network statically.

2. Change the name server information at the source. The DHCP server that provides it.

3. Modify **/etc/dhcpcd.conf** if you are assigning host addresses and name servers using dhcp.

4. Using **netplan**. Unfortunately this is new to me and I have not had a chance to look into it.

!!! note
    Option 2 is probably the best. Though it will not be a good choice for your name servers themselves. The name servers need to list their own interfaces first in the **resolv.conf** file

    Options 1, 3 and 4 are good for the name servers you will be configuring.

If you do not have a **/etc/dhcpcd.conf** you can install and configure it using:

```
apt install dhcpcd
systemctl enable dhcpcd
systemctl start dhcpcd
```

#### The dhcpcd approach

Open **/etc/dhcpcd.conf**

You should find something like this. But it will be different based on your own network address space and other details.
```
# Example static IP configuration:
#interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1
```
The new information should look similar to this.
```
# Example static IP configuration:
interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1
static domain_name_servers=192.168.11.10 192.168.11.20
static domain_search=example.com
```

- Uncomment your **interface** line
- Uncomment your **static domain_name_servers** and list the IP Addresses of your name servers.
- Optionally add your **domain_search**. This will allow you to access machines using the single host name.

Restart the **dhcpcd** service
```
systemctl restart dhcpdcd
```

Your **/etc/resolv.conf** should now reflect these changes but retain some of its original settings.
You will need to make changes on all machines in your network to use the new primary, and secondary name server once they are running.

You now should have a functioning caching name server.

## Time to get Authoritative!
Having a caching name server is nice. But it's not really that useful. The real benefit comes from controlling your own domain within your network. As well as being able to provide reverse DNS entries.

### What are reverse DNS entries?
We have all probably watched a police drama where they use a reverse lookup on a phone number to get a name or address. Its basically the same.
```
dig -x 192.168.11.1
```
Response:
```
...
...
;; ANSWER SECTION:
1.11.168.192.in-addr.arpa. 86400 IN	PTR	router.example.com.
..
..
```
!!! note "Slow initial network connections?"
    Have you ever noticed that sometimes initial connections to hosts can be slow? This is often caused by a failed reverse DNS lookup.

    The other benefit, is that reverse DNS is another way to document your network. Sure a spreadsheet is useful.

    But sometimes a simple **dig -x** will give you the information you need provided you keep your zone files up to date.

### Setting a Reverse Zone file.

#### Creating the reverse zone file.

Let's copy the **db.empty** to a new file called **db.192.168.11**
```
cp db.empty db.192.168.11
```
Original file:
```
; BIND reverse data file for empty rfc1918 zone
;
; DO NOT EDIT THIS FILE - it is used for multiple zones.
; Instead, copy it, edit named.conf, and use that copy.
;
$TTL	86400
@	IN	SOA	localhost. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	localhost.
```
Let's delete the first 5 lines. We don't need these comments.
Next we are going to edit the **"localhost. root.localhost."** portion and
replace **localhost.** with **ns1.example.com.** and **root.localhost.** with **root.example.com.**

The line should now look like:
```
@	IN	SOA	ns1.example.com. root.example.com. (

```
**What does this mean?**

We are saying that ns1.example.com is the SOA (Start Of Authority) for this zone record. And the contact email address for this zone is root@example.com. This may not be important for a purely internally hosted service, but it's good knowledge to have.

!!! note "An important point."
    **Always** update the serial number when you edit any zone files. If you forget to do this. The zone data will not propagate to the name servers correctly. The general format that has been used for the serial number is in the form of: **'YEARMONTHDATESEQUENCE'**. Assume todays date was *20201122* the Serial would be **2020112201**. If you edit the zone file on that date. If you edit it a second time on the same day, then increment the sequence. The serial would now be **2020112202**.

Edit the serial to match your actual date. Try and keep everything nicely lined up.
!!! Note "Zone file format"
    The file uses tab spacing.

After editing you want to have something that looks like the following:
```
$TTL	86400
@	IN	SOA	ns1.example.com. root.example.com. (
	                 2020112201		; Serial
			             604800		; Refresh
			              86400		; Retry
			            2419200		; Expire
                          86400 )  	; Negative Cache TTL
;
; Name servers
	 IN	NS	  ns1.example.com.
	 IN	NS	  ns2.example.com.

1	IN	PTR	 router.example.com.
..
..
35   IN     PTR     hassio.example.com.
40   IN     PTR     printer.example.com.
```

!!! note "Reverse records end with a ."
    These lines end with a **.**(period / full stop). This tells DNS not to append to the record.

Add any other records that you want to have in your reverse DNS records.

#### Make the server aware of our new reverse zone file.

Next lets make DNS aware of this **db.192.168.11** file.

For simplicity edit the **zones.rfc1918** file and add these lines:
```
zone "11.168.192.in-addr.arpa" {
  type master;
  file "/etc/bind/db.192.168.11";
};
```
just above the line shown here.
```
zone "168.192.in-addr.arpa" { type master; file "/etc/bind/db.empty"; };
```

### Setting a forward zone record.

Next we want to add our more standard forward lookups.

#### Creating db.example.com

Again copy the **db.empty** to a file called **db.example.com**. Make the same basic edits for the SOA line and serial. Then add your host records.

Here is the example.
```
$TTL	604800
@	IN	SOA	ns1.example.com. root.example.com. (
		                    2020112201		; Serial
			                    604800		; Refresh
			                     86400		; Retry
			                   2419200		; Expire
			                    604800 )  	; Negative Cache TTL


                        IN  NS  ns1.example.com.
                        IN  NS  ns2.example.com.

ns1.example.com.        IN	A	192.168.11.10
ns2.example.com.        IN	A	192.168.11.20

hassio.example.com.     IN	A	192.168.11.35
printer.example.com.    IN  A   192.168.11.40

; External Servers/Services
blog.example.com.       IN  CNAME ghs.google.com.
bogus.example.com.      IN  A 203.X.X.X
```

!!! warning
    **The big gotcha that follows.**

    The pickle in this pie is going to be if you use the same domain for your internal network and anything that you have hosted outside on the internet. You need to duplicate these entries in your new zone file.

    Let's say you are using Google's Blogger to host a site.

    **https://blog.example.com**

    Out side your own network this resolves to **172.217.175.83** for example

    We need to duplicate this sort of entry in our new zone file.
    If you were looking carefully you might have noticed the entry above under **External Servers/Services**


#### Adding the zone file to the DNS Server.

Add this db file to **named.conf.local** just below:
```
//
// Do any local configuration here
//
```

```
zone "example.com" {
	type master;
	file "/etc/bind/db.example.com";
	//allow-transfer { 192.168.11.20; };
};
```
Since there is no secondary DNS server yet. We can leave the **allow-transfer** as a comment. Uncomment this after you have a secondary server configured.

You can again use **named-checkconf** to check for issues. Then restart the bind9 with
```
systemctl reload bind9
```

You should now be able to use **dig** or **nslookup** to find hosts on your network.

You now have a fully functioning primary cache and authoritative DNS server.

The next step would be to set up your secondary DNS server to provide redundancy. You could also setup a third or fourth.

Do keep in mind this is only accessible from within your home network. And does not work when you are connected to external networks. So it does not affect any of your existing externally hosted services.

## Adding a Secondary Name Server.

This will involve using the same steps to set up a caching server that we did when setting up NS1.
So I will list these commands in quick succession.

### Update and install packages.

```
apt update && apt upgrade
apt install bind9 dnsutils
```

### Create named.conf.acl

Create the **named.conf.acl** file in **/etc/bind/** and add your acl data
```
acl "internal" {
	192.168.11.0/24;
	127.0.0.1;
	::1;
};
```
Get the **named.conf.acl** included into **named.conf** by adding the following to **named.conf** near the top.

```
include "/etc/bind/named.conf.acl";
```

### Update named.conf.options.

Edit **named.conf.options** as we did previously. But replace .10 with .20 to match the servers IP address.
```
options {
	directory "/var/cache/bind";

	recursion yes;
	allow-recursion { internal; };
	listen-on { 127.0.0.1; 192.168.11.20; };
	allow-transfer { none; };

```
!!! note "listen-on"
    Make sure you use the internal interface of the secondary server.

### Update your forwarders
```
forwarders {
  8.8.8.8;
  xx.xx.xx.xx;
};
```
And add the following if you are using forwarders.
```
//dnssec-validation auto;
dnssec-validation no;
```
### Update named.conf.local

Edit the **named.conf.local** to include **zones.rfc1918**

```
// Consider adding the 1918 zones here, if they are not used in your
// organization
include "/etc/bind/zones.rfc1918";

```
But don't do anything more at this stage. This should result in a working cache server.

### Enable and start Bind9

```
systemctl enable bind9
systemctl start bind9
```

Feel free to test using:
```
nslookup @localhost www.google.com
```

### Update **/etc/resolv.conf** using dhcpcd option

#### Install dhcpcd if missing
```
apt install dhcpcd
systemctl enable dhcpcd
systemctl start dhcpcd
```

#### Edit /etc/dhcpcd.conf

The new information should look similar to this.
```
# Example static IP configuration:
interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1
static domain_name_servers=192.168.11.20 192.168.11.10
static domain_search=example.com
```

#### Restart dhcpdcd
```
systemctl restart dhcpdcd
```

## Share zone data with the secondary.

!!! warning
    These next steps should be done on the primary name server.

On your primary server let's edit the **named.conf.options** file and add the following:

```
notify yes;
also-notify { 192.168.11.20; };
```
This means that when ever we edit our zone files on the primary name server, the secondary will be notified and will pull the updated zone information without waiting for the zones TTL (Time To Live) to expire.

We will now edit the previously created zone files, and add zone transfer ability.

Edit **zones.rfc1918** and add the **allow-transfer** line.
```
zone "11.168.192.in-addr.arpa" {
  type master;
  file "/etc/bind/db.192.168.11";
  allow-transfer { 192.168.11.20; };
};
```
Add the same **allow-transfer** line to any other zone files you have created.

Check the configuration and reload.
```
systemctl reload bind9
```

### Secondary server named.conf.local

!!! warning "Steps done on secondary name server"
    These steps are to be done on the secondary name serve only.

We can now turn our attention to the secondary name server and configure it to get zone data from the primary which will make it authoritative for our zones.

In this case we just need to update the **named.conf.local** file so that the server knows about the zones. Add the following configuration.

```
//
// Do any local configuration here
//
zone "example.com" {
    type slave;
    file "db..example.com";
    masters { 192.168.11.10; };
};

zone "11.168.192.in-addr.arpa" {
    type slave;
    file "db.192.168.11";
    masters { 192.168.11.10; };
};
```

This basically says that for the zone file we are a secondary (slave) and that the source of all truth is our primary server.

You can reload bind9
```
systemctl reload bind9
```
or
```
rndc reload
```


That should conclude getting the name servers up and running and answering queries.

You still need to configure your network equipment to use these new servers.
