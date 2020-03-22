# RedHat / CentOS / Fedora

## RedHat/CentOS vs Fedora
If you are setting up a project for more than just your self, you will probably want to use RedHat or CentOS.  Fedora
has a very short release cycle and can cause upgrade issues for you in a production envrionment.  However, as the major
release of RedHat/CentOS ages, you will start to run into more issues with version obsolescence.  It can be tempting to
just use Fedora to get around some of these issues, but you need to make your own considerations about security,
stability, and the reasons to choose one distro over the other.  A good example of this is PHP 7 in RedHat 7.  By
default RedHat 7 ships PHP 5.4 and has kept this through all the point releases.  However, PHP no longer supports this
version and you have to implement one of the workarounds to upgrade to PHP 7.


## Docker
`dnf install podman; alias docker=podman`

Podman is compatible with Docker and OCI  Containers, is daemonless, can run as root or in rootless mode, and is what's
supported by RedHat.  There is also podman-compose, but that may not be a 1-1 with docker-compose on all features.

Docker will not run out of the box in Fedora 31 and may have other issues installing with RedHat and Centos.  Fedora
switched to cgroups v2 by default.  If you must use docker, you can modify your grub menu entry to entry to use cgroups
v1.

To switch to cgroups v1 and break Podman for non-root users, you can append `systemd.unified_cgroup_hierarchy=0` to the
end of `GRUB_CMDLINE_LINUX=[...]` in /etc/default/grub, re-build the grub boot menu, and reboot.
```bash
# Add boot parameter, re-build grub menu, and reboot
sed -ie 's/\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 systemd.unified_cgroup_hierarchy=0/' /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
shutdown -r now
```


## SELinux
If you are going the non-container route, you WILL run into SELinux denials.  For any given project, if you have
followed all the instructions and it still doesn't work, check what was blocked by SELinux.  Find out why and allow the
exception if you know why you are doing it.  There is NO reason to turn SELinux off.  Please do not turn it off.  You
don't even need to turn it off to confirm SELinux is blocking what you want to do, there is a log that tells you exactly
why it was blocked.  Just learn to use the tool.  If you ever run across a guide that tells you to turn it off, then be
highly skeptical of anything else it tells you.

Read the documentation: [Using SELinux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index)

### Some quick tips to get you started
These are some of the most common issues you will run into and how to correct them.

* Search the audit log for all denials.
  <br> `ausearch -m avc`
* List the security context for processes and files
  <br>`ps -eZ`
  <br>`ls -Zl`
* Permanently add the read-write context to a directory
  <br> `semanage fcontext -a -t httpd_sys_rw_content_t "/readwrite/path(/.*)?"`
  <br> `restorecon -v /readwrite/path/`
* Allow httpd or nginx to act as a reverse proxy.
  <br> `setsebool -P httpd_can_network_connect=1`
* List all the SELinux permissions for a given daemon.
  <br> `/usr/sbin/getsebool -a | grep httpd`

