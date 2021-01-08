# SnapRAID-BTRFS

## Background

This guide builds on the [Perfect Media Server](https://perfectmediaserver.com/) setup by using BTRFS for data drives and taking advantage of [snapraid-btrfs](https://github.com/automorphism88/snapraid-btrfs) to manage SnapRAID operations using read-only BTRFS snapshots where possible. One of the main limitations of SnapRAID is that there is a dependence on live data being continuously accessible and unchanging not only for complete parity sync purposes, but also for complete recovery in the event that a drive needs to be rebuilt from parity.

Using snapraid-btrfs, there is no requirement to stop any services or ensure that the live filesystem is free of any new files or changes to existing files.

From the snapraid-btrfs repo:

> ### Why use snapraid-btrfs?
>
> A: A major disadvantage of SnapRAID is that the parity files are not updated in realtime. This not only means that new files are not protected until after running `snapraid sync`, but also creates a form of "write hole" where if files are modified or deleted, some protection of other files which share the same parity block(s) is lost until another sync is completed, since if other files need to be restored using the `snapraid fix` command, the deleted or modified files will not be available, just as if the disk had failed, or developed a bad sector. This problem can be mitigated by adding additional parities, since SnapRAID permits up to six, or worked around by temporarily moving files into a directory that is excluded in your SnapRAID config file, then completing a sync to remove them from the parity before deleting them. However, this problem is a textbook use case for btrfs snapshots.
>
> By using read-only snapshots when we do a `snapraid sync`, we ensure that if we modify or delete files during or after the sync, we can always restore the array to the state it was in at the time the read-only snapshots were created, so long as the snapshots are not deleted until another sync is completed with new snapshots. This use case for btrfs snapshots is similar to using `btrfs send/receive` to back up a live filesystem, where the use of read-only snapshots guarantees the consistency of the result, while using `dd` would require that the entire filesystem be mounted read-only to prevent corruption caused by writes to the live filesystem during the backup.

## Prerequisites

Install Ubuntu 20.04 as per the [Manual Install on Bare Metal](https://perfectmediaserver.com/installation/manual-install/) guide at Perfect Media Server, and follow the steps until the end of the _Brand new drives_ section, resulting in a bare filesystem on each drive.

## Drive setup

### Formatting the drives

Install BTRFS tools:

```bash
apt install btrfs-progs
```

Format each data drive using BTRFS.

!!! note
    Note that for convenience this guide uses filesystem labels for mountpoints in `/etc/fstab`. It is user preference to use `/dev/disk/by-id`, `/dev/disk/by-uuid` , or other method.

```bash
mkfs.btrfs -L mergerfsdisk1 /dev/sdX1
```

### Parity drive(s)

!!! note
    Note that although there's no harm with using BTRFS for the SnapRAID parity, there isn't any benefit from doing so to use snapraid-btrfs. It is recommended to use ext4 for the SnapRAID parity.

Format parity drive(s) using `mkfs.ext4` and mount as per the Perfect Media Server installation guide.

### Data subvolumes

To use BTRFS snapshots as this guide suggests, the data itself will reside in a BTRFS `/data` subvolume that needs to be created on each drive. Create mountpoints for the BTRFS root filesystems:

```bash
mkdir -p /mnt/btrfs-roots/mergerfsdisk{1,2,3,4}
```

Add entries in `/etc/fstab` for the root filesystems:

```conf
### /etc/fstab BTRFS root filesystems
LABEL=mergerfsdisk1 /mnt/btrfs-roots/mergerfsdisk1 btrfs defaults 0 0
LABEL=mergerfsdisk2 /mnt/btrfs-roots/mergerfsdisk2 btrfs defaults 0 0
...
```

Mount each disk and create BTRFS subvolumes on each root filesystem:

```bash
mount /mnt/btrfs-roots/mergerfsdisk1
btrfs subvolume create /mnt/btrfs-roots/mergerfsdisk1/data
mount /mnt/btrfs-roots/mergerfsdisk2
btrfs subvolume create /mnt/btrfs-roots/mergerfsdisk2/data
...
```

Create mountpoints for the array as described at Perfect Media Server. For example:

```bash
mkdir /mnt/disk{1,2,3,4}
```

Add entries in `/etc/fstab` for data subvolumes:

```conf
### /etc/fstab BTRFS data subvolumes
LABEL=mergerfsdisk1 /mnt/disk1 btrfs subvol=/data 0 0
LABEL=mergerfsdisk2 /mnt/disk2 btrfs subvol=/data 0 0
...
```

Mount the data drives:

```bash
mount /mnt/disk1
mount /mnt/disk2
...
```

### Content subvolumes

The SnapRAID `.content` files do not need to be snapshotted and it is recommended that any `.content` files stored on the array be in a separate BTRFS subvolumes.

Create subvolumes and mountpoints for `.content` files:

```bash
btrfs subvolume create /mnt/btrfs-roots/mergerfsdisk1/content
btrfs subvolume create /mnt/btrfs-roots/mergerfsdisk2/content
mkdir -p /mnt/snapraid-content/disk{1,2}
```

Add entries in `/etc/fstab` for content subvolumes:

```conf
### /etc/fstab BTRFS content subvolumes
LABEL=mergerfsdisk1 /mnt/snapraid-content/disk1 btrfs subvol=/content 0 0
LABEL=mergerfsdisk2 /mnt/snapraid-content/disk2 btrfs subvol=/content 0 0
...
```

### BTRFS root filesystem unmount

Once the data and content subvolumes are created and mounted, the BTRFS root filesystem can be unmounted.

```bash
umount /mnt/btrfs-roots/mergerfsdisk1
umount /mnt/btrfs-roots/mergerfsdisk2
...
```

The entries for the BTRFS root filesystems in `/etc/fstab` can also be commented out.

## MergerFS

The fstab steps for the MergerFS pool are unchanged from the Perfect Media Server installation guide. Create a `/mnt/storage` mountpoint and follow [fstab entries](https://perfectmediaserver.com/installation/manual-install/#fstab-entries) section of the guide.

## SnapRAID setup

Install SnapRAID as per the Perfect Media Server installation guide. To configure SnapRAID, ensure it points to the correct mount points that were created earlier. Using the example at Perfect Media Server as a basis, and updating for the mountpoints above results in the following:

```conf
# SnapRAID configuration file

# Parity location(s)
1-parity /mnt/parity1/snapraid.parity
2-parity /mnt/parity2/snapraid.parity

# Content file location(s)
content /var/snapraid.content
content /mnt/snapraid-content/disk1/snapraid.content
content /mnt/snapraid-content/disk2/snapraid.content

# Data disks
data d1 /mnt/disk1
data d2 /mnt/disk2
data d3 /mnt/disk3
data d4 /mnt/disk4

# Excludes hidden files and directories
exclude *.unrecoverable
exclude /tmp/
exclude /lost+found/
exclude downloads/
exclude appdata/
exclude *.!sync
exclude /.snapshots/
```

At this point, the system is set up to run native SnapRAID as described in the Perfect Media Server installation guide, the only difference being that the data is stored on BTRFS subvolumes.

The remainder of this guide will discuss how to leverage the BTRFS subvolumes with snapshots, and using those for SnapRAID parity.

## Snapper setup

### Snapper installation and configuration template

In order to create and work with BTRFS snapshots, snapraid-btrfs uses Snapper. Install it as follows:

```bash
apt install snapper
```

Snapper requires that configuration profiles are created for each subvolume that requires snapshots. It has the ability to take new snapshots and cleanup old ones on a regular basis using _timeline_ policies.

!!! note
    For the purposes of this guide, the timeline-based snapshots are not required for snapraid-btrfs. snapraid-btrfs will create its own snapshots in conjunction with SnapRAID operations.

The default Snapper configuration template will be used as a basis for a minimal template for MergerFS data drives.

```bash
cd /etc/snapper/config-templates
cp default mergerfsdisk
```

To disable timeline-based snapshots, edit the  `/etc/snapper/config-templates/mergerfsdisk` template as follows:

```conf
...
# create hourly snapshots
TIMELINE_CREATE="no"
...
```

Additional config options can be found at the [snapper-configs man page](http://snapper.io/manpages/snapper-configs.html).

### Snapper profiles for data subvolumes

Create Snapper profiles for each data subvolume created earlier using the `mergerfsdisk` template.

```bash
snapper -c mergerfsdisk1 create-config -t mergerfsdisk /mnt/disk1
snapper -c mergerfsdisk2 create-config -t mergerfsdisk /mnt/disk2
...
```

The resultant config files can be found at `/etc/snapper/configs` and the subvolumes that they relate to can be verified by running the following:

```bash
snapper list-configs
```

## snapraid-btrfs setup

Install [snapraid-btrfs](https://github.com/automorphism88/snapraid-btrfs) by cloning the Git repo and copying the `snapraid-btrfs` script to your system.

```bash
git clone https://github.com/automorphism88/snapraid-btrfs.git
cd snapraid-btrfs
cp snapraid-btrfs /usr/local/bin
chmod +x /usr/local/bin/snapraid-btrfs
```

Verify that  snapraid-btrfs is successfully able to see Snapper configs for each data subvolume by running the following:

```bash
snapraid-btrfs ls
```

At this point, any `snapraid <command>` can be run as as `snapraid-btrfs <command>`. Depending on the command, `snapraid-btrfs` will either take a snapshot, use an existing latest snapshot, or use the live filesystem before passing that command on to SnapRAID for processing.

## Automatic parity calculation - snapraid-btrfs-runner

To automate daily parity sync and scrub operations using snapraid-btrfs, this guide uses [snapraid-btrfs-runner](https://github.com/fmoledina/snapraid-btrfs-runner) based on the upstream [snapraid-runner](https://github.com/Chronial/snapraid-runner) tool that is commonly used for SnapRAID automation.

snapraid-btrfs-runner conducts the same basic tasks as snapraid-runner, including `diff`, `sync`, and `scrub` operations.

Install snapraid-btrfs-runner by cloning the repository:

```bash
git clone https://github.com/fmoledina/snapraid-btrfs-runner.git /opt/snapraid-btrfs-runner
```

Create a configuration file based on the example provided at `/opt/snapraid-btrfs-runner/snapraid-btrfs-runner.conf.example`. All of the snapraid-runner options are present, with additional options available for snapraid-btrfs and Snapper.

Required config parameters are as follows:

- `snapraid-btrfs.executable` location
- `snapper.executable` location
- `snapraid.executable` location
- `snapraid.config` location

Other config parameters of interest are as follows:

- `snapraid-btrfs.cleanup`: Upon a successful run of snapraid-btrfs-runner, any interim snapshots created during the process will be removed, leaving only the `snapraid-btrfs=synced` snapshot. Defaults to `true`.
- Other options specified at the Perfect Media Server installation guide.

Scheduling can be set either via cron or SystemD timers. This guide provides a basic SystemD timer as follows.

Contents of `/etc/systemd/system/snapraid-btrfs-runner.service`:

```conf
[Unit]
Description=Run snapraid-btrfs-runner every night

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /opt/snapraid-btrfs-runner/snapraid-btrfs-runner.py -c /opt/snapraid-btrfs-runner/snapraid-btrfs-runner.conf
```

Contents of `/etc/systemd/system/snapraid-btrfs-runner.timer`:

```conf
[Unit]
Description=Run snapraid-btrfs-runner every night

[Timer]
OnCalendar=*-*-* 03:00:00
RandomizedDeleySec=30m

[Install]
WantedBy=timers.target
```

Enable using:

```bash
systemctl enable snapraid-btrfs-runner.timer
systemctl start snapraid-btrfs-runner.timer
```
