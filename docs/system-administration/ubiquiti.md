# Ubiquiti

This page contains information relating to the Ubiquiti line of products.

## Adopt a new Access Point with remote Unifi controller software

If your Unifi controller software doesn't run on your LAN it is neccessary to tell the AP where it is. This allows the AP to be 'adopted' by the controller and have its configuration managed by it.

To do this you will need to SSH to the AP (default user and password is `ubnt`).

    ssh <ip-of-access-point>
    set-inform http://<controller-url>:8080/inform

Once you've done this, the AP should show up almost immediately in the interface of your Unifi controller saying 'pending adoption'.

Adopt the AP and configuration for that site will be automatically applied.

!!! note 
    After adoption the SSH password will be changed from ubnt/ubnt. You can modify the post adoption Unifi SSH username and password in the controller software by enabling 'advanced features' and then configuring your desired credentials under `Site -> Device Authentication`.