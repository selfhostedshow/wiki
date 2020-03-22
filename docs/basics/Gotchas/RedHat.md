# RedHat / CentOS / Fedora

## RedHat/CentOS vs Fedora
As the major release of RedHat/CentOS ages more and more, you will start to run into more and more issues.  It can be
tempting to just use Fedora to get around some of these issues.  But you need to make your own considerations about
security and the reasons to choose one distro over the other.  A good example of what can be frustrating is version
obsolescence on an upstream project but RedHat stuck at an older stable revision.  PHP 7 was particularly annoying to
deal with prior to RedHat 8 as RedHat 7 was stuck with 5.4 by default.


## Docker
`dnf install podman; alias docker=podman`

Podman is mostly compatible, doesn't use a daemon, can run in user space, and is what's supported by RedHat.  Thre is
also podman-compose, but that may not be a 1-1 with docker-compose on all features.

Docker will not run out of the box in Fedora 31 and may have other issues installing with RedHat and Centos.  Fedora
switched to cgroups v2 by default.  If you must use docker, you can modify your grub menu entry to entry to use cgroups
v1.

These settings will break podman for non-root users:
* edit /etc/default/grub and add a parameter to the end of GRUB_CMDLINE_LINUX
: `GRUB_CMDLINE_LINUX = "[...] systemd.unified_cgroup_hierarchy=0"`
* `grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg`


## SELinux
If you are going the non-container route, you WILL run into SELinux denials.  For any given project, if you have
followed all the instructions and it still doesn't work, check what was blocked by SELinux.  Find out why and allow the
exception if you know why you are doing it.  There is NO reason to turn SELinux off.  Please do not turn it off.  Just
learn to use the tool.  If you ever run across a guide that tells you to turn it off, then be highly skeptical of
anything else it tells you.

Read the documentation: [Using SELinux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index)

### Some quick tips to get you started
These are some of the most common issues you will run into and how to correct them.

* The security cotext, processes and files will all have a security context that defines the group of permissions they
  have.  You can add more permissions as needed as some things are disabled out of the box.
* Search the audit log for all denials.
  <br> `ausearch -m avc`
* List the security context of processes and files.
  <br> `ps -eZ` `ls -Zl`
* Permanently add the read-write context to a directory
  <br> `semanage fcontext -a -t httpd_sys_rw_content_t "/readwrite/path(/.*)?"`
  <br> `restorecon -v /readwrite/path/`
* Allow httpd or nginx to act as a reverse proxy.
  <br> `setsebool -P httpd_can_network_connect=1`
* List all the SELinux permissions for a given daemon.
  <br> `/usr/sbin/getsebool -a | grep httpd`

