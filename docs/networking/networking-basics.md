# Networking Basics

> Written by Dan Ford and originally published on <a href="https://dlford.io/computer-networking-binary-hex-explained/" target="_blank" rel="noopener noreferrer">dlford.io</a>.<br />
> Copyright &copy; 2019 dlford.io all rights reserved.

This article is written with the intent of providing a basic understanding of computer networking and IP addressing concepts, which require a basic understanding of binary and hex. I've done my best to make it easy to follow for somebody with no experience on this topic. 

_Note: I use the term "modem" very loosely in this article because most consumer modems these days have a built in switch and routing functions. You should be aware that technically a modem does not do routing, in only modulates a signal out to your ISP. In the context of this article I refer to a modem as a modem/router combo unit, when I say "router or modem", I am referring to whichever routing device your system is directly connected to._

## Basic Network Settings

### Discover Your Network

In the context of a home network, you most likely have a modem or router handling DHCP, DNS, and routing for your network. The first thing you need to do is find the IP address of your router or modem on the network. An IP address is a string of numbers separated by decimal points, that identifies each computer on a network, and must therefore be unique to each computer on the same network.

- Windows
  - Right-click the start button, and choose Windows PowerShell
  - Type the command `ipconfig | findstr /i "Gateway"`
- Mac
  - Go to Applications > Utilities, and double click on Terminal
  - Type the command `netstat -nr | grep default`
- Linux
  - Open a terminal shell, the method for this varies by distribution, on Ubuntu you can use the hotkey `control` + `shift` + `t`
  - Type the command `ip route | grep default`

You should get a value of something similar to `192.168.0.1`, this is the IP address of your gateway. Open a web browser and put this number in the address bar with `http://` in front of it, for example `http://192.168.0.1`

You will need to log in to this device, if you don't have the username and password, it may be on a sticker on the bottom of the unit (you should also change this after logging in to make your network more secure!). If it's not on a sticker, you'll have to look in the user manual for your modem or router, or search the web for "_(model number of your modem or router) default password_".

Once you've logged in, look for DHCP settings in the menu, it's likely under a "network settings" or "LAN settings" tab. Here you will find the important network settings for your home network:

- Network Range: The range of IP addresses in the local network, this may be expressed as CIDR or a subnet mask as explained later in this article, or just as a simple range like `192.168.0.0 - 192.168.0.255`
- DHCP Range: The range of IP addresses that are handed out automatically by the DHCP server (more on this later as well).

if you are setting up a host with a static IP address, you'll want to make sure it is given an IP address outside of the DHCP range so that address doesn't get automatically handed out to another host and cause a conflict, but within the network range so it can still communicate to other hosts within the local network.

Note: If you are using a router, you most likely have two subnets in use, one provided by the modem, and another from the router. Keep in mind that hosts behind the router can communicate with hosts behind the modem, but not the other way around, unless the router is configured to use the same subnet as the modem or a custom route is defined which is not usually the case by default (more information on subnets is provided later in this article).

For example, in the diagram below:

- Host A sends a request to host B
  - Host B is not in the same subnet as host A (192.168.1.x/24)
  - Host A sends the request to its gateway (Router)
  - Router can find host B is on its own subnet (192.168.0.x/24) and routes the request to host B
  - Host A can talk to host B
- Host B sends a request to host A
  - Host A is not in the same subnet as host B (192.168.0.x/24)
  - Host B sends the request to its gateway (Modem)
  - Modem is not aware of host A's subnet (192.168.1.x/24), and is unable to find host A or route traffic to it
  - Host B can **not** talk to host A

```text
Internet
       |
       |
     Modem (Public IP Address)
     Subnet 192.168.0.1/24
      /  \
     /    \
    /      \
   /        \
  |       Host B (192.168.0.3/24)
  |
  |
Router (192.168.0.2/24)
Subnet 192.168.1.1/24
  |
  |
Host A (192.168.1.2/24)
```

### Gateway

The gateway, as the name implies, is a path for traffic that is destined for a host outside of the local network range. This is usually the IP address of your router or modem on a home network, setting the incorrect gateway or none at all will make anything outside of your local network unreachable, because there is no known path to any external host.

### DHCP

DHCP, or Dynamic Host Configuration Protocol, hands out IP addresses to new hosts on a network so no manual configuration is required. Without DHCP, you would have to manually set a unique IP address, and the subnet mask, gateway, and DNS settings for each device on your network.

### DNS

DNS, or Domain Name System, is a lookup service that translates a hostname like `google.com` for example, to an IP address. This is usually set to your modem or router's IP address by default (same as the gateway address), which will in turn use the DNS servers provided by your ISP (Internet Service Provider).

## Binary and Hex

I don't want to go too far in the woods on this because it is the steepest part of the learning curve, but it is necessary to have an understanding of binary and hex before we get into IP addressing.

Let's start with something familiar to compare the core concepts with, this may feel like grade school but revisiting these concepts in detail will help you in understanding binary and hex, so stay with me here. We will go over the standard base 10 numbering system in explicit detail, and then cover binary and hex in the same manner so you can see that the mathematical concepts are the same, only the numbers change.

_There are a ton of shortcuts for converting between base 10, binary, and hex. Those shortcuts are very handy for someone who already knows the core concepts, but only serve to add confusion for someone trying to learn the concepts, so I encourage you to ignore any shortcuts until you are comfortable doing things the long way as shown here, you can pick up the shortcuts later when you have a solid grasp on the math involved._

### Concepts

I am sure you are very comfortable in the base 10 numbering system we use every day, base 10 uses _10_ characters as the name implies, those characters are 0, 1, 2, 3, 4, 5, 6, 7, 8, and 9.

The _places_ (1's, 10's, 100's, etc), are determined by the base of the numbering system, or the number of characters used. The first _place_ is always the _1's place_, and we use this formula to determine the next _place_:

```text
this place * base = next place
```

For example, to get from the 1's place to the 1000's place:

```text
1 (this place) * 10 (base) = 10 (next place)
10 (this place) * 10 (base) = 100 (next place)
100 (this place) * 10 (base) = 1000 (next place)
```

Using this formula, we can say that the first five _places_ in the base 10 numbering system are 1, 10, 100, 1,000, and 10,000.

When we exceed the last character available, (9 in this case), we start back at _0_ and carry the 1 to the next position (the 10's place).

_Places_ are merely a representation of grouped values, for example a value of 3 in the 100's place means there are 3 groups of 100, which is the same as 30 groups of 10, or 300 groups of 1.

If you understand these concepts, you already understand binary and hex, you just may not know it yet, let's work through some examples to show you what I mean.

### Examples

#### Base 10

Let's calculate the number 209 in base 10, first we need to determine the _places_ it will occupy.

Is the number 209 greater than 1? Yes, calculate the next _place_.

```text
1 (this place) * 10 (base) = 10
```

Is the number 209 greater than 10? Yes, calculate the next _place_

```text
10 (this place) * 10 (base) = 100
```

Is the number 209 greater than 100? Yes, calculate the next _place_

```text
100 (this place) * 10 (base) = 1000
```

Is the number 209 greater than 1000? **No**, we will only use the **1's, 10's and 100's** places.

Now we just work backward from the highest _place_ to determine each _place's_ value.

How many times will the number 100 go into 209? Twice, with a remainder of **9**. The value of the _100's place_ is **2**.

```text
209 / 100 = 2 R9
```

How many times will the number 10 go into 9? Zero times, with a remainder of **9**. The value of the _10's place_ is **0**.

```text
9 / 10 = 0 R9
```

How many times will the number 1 go into 9? Nine times, with a remainder of **0**. The value of the _1's place_ is **9**.

```text
9 / 1 = 9 R0
```

Now put together all the _places_ to get the final number. The number 209 represented in base 10 is:

```text
2       0       9
100's   10's    1's
```

This is _exactly_ how binary and hex work, but they use a different amount of characters, and therefore have a different _base_, and therefore different _places_.

#### Binary (Base 2)

In base 2, we have only 2 characters available: **0, and 1**.

Now let's calculate the number 209 in base 2, first we need to determine the _places_ it will occupy.

Is the number 209 greater than 1? Yes, calculate the next _place_.

```text
1 (this place) * 2 (base) = 2
```

Is the number 209 greater than 2? Yes, calculate the next _place_

```text
2 (this place) * 2 (base) = 4
```

Is the number 209 greater than 4? Yes, calculate the next _place_

```text
4 (this place) * 2 (base) = 8
```

Is the number 209 greater than 8? Yes, calculate the next _place_

```text
8 (this place) * 2 (base) = 16
```

Is the number 209 greater than 16? Yes, calculate the next _place_

```text
16 (this place) * 2 (base) = 32
```

Is the number 209 greater than 32? Yes, calculate the next _place_

```text
32 (this place) * 2 (base) = 64
```

Is the number 209 greater than 64? Yes, calculate the next _place_

```text
64 (this place) * 2 (base) = 128
```

Is the number 209 greater than 128? Yes, calculate the next _place_

```text
128 (this place) * 2 (base) = 256
```

Is the number 209 greater than 256? **No**, we will use the **1's, 2's, 4's, 8's, 16's, 32's, 64's, and 128's** places.

Now we just work backward from the highest _place_ to determine each _place's_ value.

How many times will the number 128 go into 209? Once, with a remainder of **81**. The value of the _128's place_ is **1**.

```text
209 / 128 = 1 R81
```

How many times will the number 64 go into 81? Once, with a remainder of **17**. The value of the _64's place_ is **1**.

```text
81 / 64 = 1 R17
```

How many times will the number 32 go into 17? Zero times, with a remainder of **17**. The value of the _32's place_ is **0**.

```text
17 / 32 = 0 R17
```

How many times will the number 16 go into 17? Once, with a remainder of **1**. The value of the _16's place_ is **1**.

```text
17 / 16 = 1 R1
```

How many times will the number 8 go into 1? Zero times, with a remainder of **1**. The value of the _8's place_ is **0**.

```text
1 / 8 = 0 R1
```

How many times will the number 4 go into 1? Zero times, with a remainder of **1**. The value of the _4's place_ is **0**.

```text
1 / 4 = 0 R1
```

How many times will the number 2 go into 1? Zero times, with a remainder of **1**. The value of the _2's place_ is **0**.

```text
1 / 2 = 0 R1
```

How many times will the number 1 go into 1? Once, with a remainder of **0**. The value of the _1's place_ is **1**.

```text
1 / 1 = 1 R0
```

Now put together all the _places_ to get the final number (`11010001`). The number 209 represented in base 2 is:

```text
1      1      0      1      0      0      0     1
128's  64's   32's   16's   8's    4's    2's   1's
```

Converting back to base 10 is super easy, just multiply each of the _places_ by their value, and then add them up.

```text
128 * 1 = 128
64 * 1 =  64
32 * 0 =  0
16 * 1 =  16
8 * 0 =   0
4 * 0 =   0
2 * 0 =   0
1 * 1 =   1    +
--------------------
209
```

Just to drive it home, here are the numbers one through 10 expressed in binary:

```text
1  = 0001
2  = 0010
3  = 0011
4  = 0100
5  = 0101
6  = 0110
7  = 0111
8  = 1000
9  = 1001
10 = 1010
```

#### Hex (Base 16)

In base 16, we have 16 characters available, _0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, and F_ (The letters A through F represent the numbers 10 through 15), but everything else is still the same!

Now let's calculate the number 209 in base 16, first we need to determine the _places_ it will occupy.

Is the number 209 greater than 1? Yes, calculate the next _place_.

```text
1 (this place) * 16 (base) = 16
```

Is the number 209 greater than 16? Yes, calculate the next _place_

```text
16 (this place) * 16 (base) = 256
```

Is the number 209 greater than 256? **No**, we will use the **1's, and 16's** places.

Now we just work backward from the highest _place_ to determine each _place's_ value.

How many times will the number 16 go into 209? 13 times, with a remainder of **1**. The number **13** in hex is represented as the letter **D**, so the value of the _16's place_ is **D**.

```text
209 / 16 = 13 R1
```

How many times will the number 1 go into 1? Once, with a remainder of **0**. The value of the _1's place_ is **1**.

```text
1 / 1 = 1 R0
```

Now put together all the _places_ to get the final number (`D1`). The number 209 represented in base 2 is:

```text
D(13)    1
16's     1's
```

Converting back to base 10 is super easy, just multiply each of the _places_ by their value, and then add them up.

```text
16 * D(13) = 208
1 * 1 =      1      +
------------------------
209
```

## IPv4 Addresses

An IPv4 address consists of 4 bytes separated by decimal points, like `192.168.0.1` for example. A bit is one binary unit, and 8 bits make up a byte. One byte can represent any number from 0 to 255 because 255 in binary is `11111111`, and 256 in binary is `100000000`, which is 9 bits.

There are some IPv4 addresses that are reserved for private use by the Internet Assigned Numbers Authority (IANA), meaning they are not routable over the open internet. These are the only addresses that you should use within your private network unless you have purchased a static public IP address from your ISP, but even if you have you'll most likely end up using a private address behind your modem or access point that has the public IP address.

Here are the three ranges of private IPv4 addresses:

_I will cover CIDR and subnet masks down below._

| Address Range                 | CIDR           | Subnet Mask |
| ----------------------------- | -------------- | ----------- |
| 10.0.0.0 - 10.255.255.255     | 10.0.0.0/8     | 255.0.0.0   |
| 172.16.0.0 - 172.31.255.255   | 172.16.0.0/12  | 255.240.0.0 |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | 255.255.0.0 |

## Subnet Masks

This is where an understanding of binary becomes very important. A subnet mask is a number that defines a range of IP addresses and is expressed in the same format as an IP address. It is used by computer systems to determine which hosts are reachable directly in the local network; requests to any host outside of this range will be sent to the network gateway whose job it is to route the traffic to the correct destination.

Let's start with a common network `192.168.0.0` with the subnet mask `255.255.255.0`, many home routers and modems default to this network. First we need to break these out into binary:

```text
┌ Network Address 192.168.0.0 ┐
11000000.10101000.00000000.00000000
11111111.11111111.11111111.00000000
└ Subnet Mask 255.255.255.0 ┘
```

The operative word here is "mask", it's like a secret decoder ring for your network range. Any bit that is a 1 in the subnet mask is "locked" to the network range, so whatever the corresponding bit is in the network address must not change to be considered part of this range. Any bit that is a 0 in the subnet mask is a wildcard, meaning the corresponding bit in the network address can be either 0 or 1. To simplify this, let's take all the locked-in bits from the network address, and replace the wildcard bits with `*`.

```text
11000000.10101000.00000000.00000000 (Network Address)
11111111.11111111.11111111.00000000 (Subnet Mask)
-------------------------------------------------
11000000.10101000.00000000.********
```

Now to find the full range of this network, just set all the wildcard bits to 0, that's the low end, then set them all to 1, that's the high end.

```text
11000000.10101000.00000000.********
11000000.10101000.00000000.00000000 = 192.168.0.0
11000000.10101000.00000000.11111111 = 192.168.0.255
```

This network range covers the IP addresses `192.168.0.0` through `192.168.0.255`. What if we changed the subnet mask to `255.255.248.0`? This adds 3 more wildcard bits, and as a result adds more IP addresses to the range.

```text
┌ Network 192.168.0.0 ┐
11000000.10101000.00000000.00000000
11111111.11111111.11111000.00000000
└ Subnet Mask 255.255.248.0 ┘
```

```text
11000000.10101000.00000***.********
11000000.10101000.00000000.00000000 = 192.168.0.0
11000000.10101000.00000111.11111111 = 192.168.7.255
```

This changed the range to `192.168.0.0` through `192.168.7.255`, adding the addresses `192.168.1.0` through `192.168.7.255` to the previous example.

Lets do one more to drive it home, how about the network `172.16.54.0` and subnet mask `255.255.255.252`.

```text
┌ Network 172.16.54.0 ┐
10101100.00010000.00110110.00000000
11111111.11111111.11111111.11111100
└ Subnet Mask 255.255.255.252 ┘
```

```text
10101100.00010000.00110110.000000**
10101100.00010000.00110110.00000000 = 172.16.54.0
10101100.00010000.00110110.00000011 = 172.16.54.3
```

This gives us a very short range of `172.16.54.0` through `172.16.54.3`. Let's open that up to `255.248.0.0`.

```text
┌ Network 172.16.54.0 ┐
10101100.00010000.00110110.00000000
11111111.11111000.00000000.00000000
└ Subnet Mask 255.248.0.0 ┘
```

```text
10101100.00010***.********.********
10101100.00010000.00000000.00000000 = 172.16.0.0
10101100.00010111.11111111.11111111 = 172.23.255.255
```

The new range is `172.16.0.0` through `172.23.255.255`, we've added the new addresses `172.16.0.0` through `172.16.53.255`, and `172.16.54.4` through `172.23.255.255` to the range.

## CIDR Notation

You will commonly see networks referred to with a `/` and then a number at the end, `192.168.0.0/24` for example. This is Classless Inter-Domain Routing (CIDR) notation, you can think of it in simple terms as a shorthand way of expressing a subnet mask, the number after the `/` refers to the number of locked bits in the subnet mask. CIDR is sometimes referred to as "supernetting" because it's much more granular than the old class based IP addressing approach, CIDR quickly became the standard. Here are some examples:

```text
CIDR 192.168.0.34/24
IP Address 192.168.0.34
Subnet Mask 11111111.11111111.11111111.00000000
                                     ^ 24th bit

11111111.11111111.11111111.00000000 = 255.255.255.0
```

```text
CIDR 10.43.43.12/30
IP Address 10.43.43.12
Subnet Mask 11111111.11111111.11111111.11111100
                                            ^ 30th bit

11111111.11111111.11111111.11111100 = 255.255.255.252
```

```text
CIDR 172.16.24.11/13
IP Address 172.16.24.11
Subnet Mask 11111111.11111000.00000000.00000000
                         ^ 13th bit

11111111.11111000.00000000.00000000 = 255.248.0.0
```

## IPv6

IPv6 is a newer standard than IPv4, with the main intention of providing significantly more unique addresses, there are also some new features and other changes compared to IPv4. It hasn't quite taken off yet, but it is very likely that IPv6 will eventually become the default because there just aren't enough unique IPv4 addresses to go around.

A complete breakdown of IPv6 is another topic for another article, it's a lot of new information to cover and my brain is pretty fried already, how about yours? But let's just get your feet wet, here is an example of a full IPv6 address:

```text
FE80:0000:0000:0000:0202:B3FF:FE1E:8329
```

Note that instead of a decimal point `.` to separate each "byte" as in IPv4, IPv6 uses a colon `:` to separate each "hex word". To give you an idea of the sheer size of the address pool in IPv6, here is the same address as above expressed in the binary format, next to the IPv4 address `192.168.0.1` also expressed in binary format:

```text
IPv6                IPv4
1111111010000000    11000000
0000000000000000    10101000
0000000000000000    00000000
0000000000000000    00000001
0000001000000010
1011001111111111
1111111000011110
1000001100101001
```

IPv6 uses 128 bit (16 byte) addresses, as apposed to 32 bit (4 byte) IPv4 addresses.

> Written by Dan Ford and originally published on <a href="https://dlford.io/computer-networking-binary-hex-explained/" target="_blank" rel="noopener noreferrer">dlford.io</a>.<br />
> Copyright &copy; 2019 dlford.io all rights reserved.

