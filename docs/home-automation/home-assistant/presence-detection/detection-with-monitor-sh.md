---
title: "Presence Detection with BLE using monitor.sh"
date: 2020-12-06
authors:
  - Adam Spann
summary: A guide to using monitor.sh with Home Assistant for presence detection.
---

I have been running [Home Assistant](https://www.home-assistant.io/hassio/) for a while. Things are going well. But I have had some issues with presence detection using the standard *device_tracker* component. Though I live in a small place, being in Tokyo, Home Assistant sometimes stops detecting phones if they are in an area of the apartment a little away from the Home Assistant server. This I suspect is due to the position of the Raspberry Pi and the building material.

Doing some research I came across a possible solution using multiple BLE devices. I have opted to use [Monitor](https://github.com/andrewjfreyer/monitor), a bash script solution.

This is a guide mostly for myself. I need to remember how it was setup. My approach has been to try and avoid rewriting my configuration and use most of my existing *tracker_device* automations.

### Setup Mosquitto (MQTT) on your Home Assistant

I configured MQTT to use a username and password. This is all that is really needed to get things started.
If MQTT is already setup. Skip this step.

### Hardware

In addition to my Home Assistant server. I have:

- Raspberry Pi Zero WH
- Raspberry Pi 2 + Bluetooth dongle

&nbsp;
### Installation
#### OS
For the most part I followed the guide at Level1Techs.

#### Setup your Raspberry Pi Zero W(H)
1. Download Raspbian
2. Image Raspbian
3. Mount the Boot Partition
4. Create wpa_supplicant.conf with this config:

```bash
country=US

ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev

update_config=1

network={

ssid="Wireless Network Name"

psk="Wireless Network Password"

key_mgmt=WPA-PSK

}
```

5. touch ssh
```bash
 touch ssh
```

Step 5 will enable ssh to your device.

#### Finding your new Pi on the network

If your network is small you can simply run:
```bash
arp -a
```
This will give you a list of devices currently connected to your network. So run this once before you power up the new Pi.

After you power up the Pi. Run the `arp` command again and see which new address appears in your list.

ssh into the new Pi using the standard username and password. Don't forget to change the password just as a matter of good security practice.

#### Packages / monitor

##### Update system and packages

Issue the follow commands

```bash
apt update && apt upgrade
apt dist-upgrade
apt install pi-bluetooth
```
Next reboot the device and login again once it's up.

##### Install git and Mosquitto

```bash
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
sudo apt-key add mosquitto-repo.gpg.key
```
If you are running Sketch
```bash
wget http://repo.mosquitto.org/debian/mosquitto-stretch.list
```
If you are running Buster
```bash
wget http://repo.mosquitto.org/debian/mosquitto-buster.list
```
then
```bash
apt-get update
```

If you have any issues. Take a look at **The Level 1 Way** guide listed below. You may need to install some additional packages.

##### Setup Monitor

```bash
pi@raspberrypi:~ $ git clone https://github.com/andrewjfreyer/monitor.git
pi@raspberrypi:~ $ cd monitor/
pi@raspberrypi:~/monitor $ chmod +x ./monitor.sh
pi@raspberrypi:~/monitor $ ./monitor.sh
```
I suggest running the command a few times to learn how monitor.sh works. Also this needs to be done to create the initial setup files that we will be editing. You might need to run the command with sudo if you are not logged in as root. When you are satisfied check that **monitor** is running with:
```bash
systemctl status monitor
```
If not:
```bash
systemctl enable monitor
systemctl start monitor
```

I will not document how I edited the **/etc/systemd/system/monitor.services** file. You will find information on options that others have used in the links below.

Next add any BT MAC addresses that you know to the **known_static_addresses** file.

One thing to note. The *alias* will be the name of the device in MQTT. If there is no alias, the MAC address will be used. More on this later.

!!! warning

    If you are monitoring a *Tile Device* do not place it in the **known_static_addresses**. This will make monitor see the device twice. Once with confidence 100% and again with 0%. The work a round that I have seen it to not place its MAC address in the file. You will need to use the MAC address instead of an alias in the sensor configuration.

**References**

- [1. Home Assistant Community - Bluetooth-le-Tracking-Issues](https://community.home-assistant.io/t/bluetooth-le-tracker-issues/97705/33)
- [2. Home Assistant Community - monitor-reliable-multi-user-distributed-bluetooth-occupancy-presence-detection](https://community.home-assistant.io/t/monitor-reliable-multi-user-distributed-bluetooth-occupancy-presence-detection/68505/1416)
- [3. GitHub - Active scanner + overrule HA 'consider_home' #183](https://github.com/andrewjfreyer/monitor/issues/183)

```bash
# ---------------------------
#
# STATIC MAC ADDRESS LIST
#
# 00:00:00:00:00:00 Alias #comment
# ---------------------------
 00:00:00:00:00:00 person1_Phone

```

Configure **mqtt_preferences** so that we can connect and publish to our MQTT topics. 

```bash
# ---------------------------
#
# MOSQUITTO PREFERENCES
#
# ---------------------------

# IP ADDRESS OR HOSTNAME OF MQTT BROKER
mqtt_address=192.168.X.X

# MQTT BROKER USERNAME
mqtt_user=mqtt_username # This is what was configured on the MQTT Server.

# MQTT BROKER PASSWORD
mqtt_password=password #Same case as username.

# MQTT PUBLISH TOPIC ROOT
mqtt_topicpath=monitor # <- most configs use this.

# PUBLISHER IDENTITY
mqtt_publisher_identity='livingarea' #<- ID for one of the Pi servers eg. Pi Zero W

# MQTT PORT
mqtt_port='1883'

# MQTT CERTIFICATE FILE
mqtt_certificate_path=''

#MQTT VERSION (EXAMPLE: 'mqttv311')
mqtt_version=''
```

!!! note
    **mqtt_topicpath** should be the same on each of your monitoring servers.

    **mqtt_publisher_identity** must be unique for each server that will be sending MQTT messages to the HA server.

Test that MQTT server is getting the new notifications from your Pi devices.

```bash
mosquitto_sub -h 192.168.X.X -u username -P passwd -t monitor/#

# Output
{"id":"00:00:00:00:00:00","confidence":"100","name":"person1_Phone",
  "manufacturer":"Apple Inc","type":"KNOWN_MAC","retained":"true",
  "timestamp":"Fri Nov 06 2020 ...."
}
```

Here we can see that devices are being seen and their *confidence level* from the *monitor.sh* is being reported.

At this point, after setting up all of the monitoring devices, it is time to move onto setting up HA.

### Home Assistant Configuration

#### Setup the sensor part of the configuration
We need to collect the MQTT messages into HA

```yaml
- platform: mqtt
  state_topic: 'monitor/front/person1_phone'
  value_template: '{{ value_json.confidence }}'
  unit_of_measurement: '%'
  name: 'Person1 Phone Front'

- platform: mqtt
  state_topic: 'monitor/livingarea/person1_phone'
  value_template: '{{ value_json.confidence }}'
  unit_of_measurement: '%'
  name: 'Person1 Phone Living Area'

```
#### Tile Device Example
```yaml
- platform: mqtt
  state_topic: 'monitor/front/XX::XX:XX:XX:XX:XX'
  value_template: '{{ value_json.confidence }}'
  unit_of_measurement: '%'
  name: 'Person1 Phone Front'

- platform: mqtt
  state_topic: 'monitor/livingarea/XX::XX:XX:XX:XX:XX'
  value_template: '{{ value_json.confidence }}'
  unit_of_measurement: '%'
  name: 'Person1 Phone Living Area'
```

!!! note
    1. I have two entries as I have two devices running **monitor** in two locations in my home.
    2. The topic is *person1_phone* which matches the alias used in the **known_static_addresses** file. If there was not an alias. These would be the actual MAC Addresses.


The next part is still a work in progress. This is still in the sensor.yaml file.

```yaml
- platform: min_max
   name: "Person1 Phone Home Confidence"
   type: mean
   round_digits: 0
   entity_ids:
     - sensor.person1_phone_front
     - sensor.person1_phone_living_area
```
This combines these two sensors and return the mean of their two values. In my case this often returns 50% since only one monitor server can detect the phone based on where it is.

Next we create a sensor that will return a 'True' or 'False' state. As mentioned my min_max generally returns 50%. So I want to have 'True' if the value is > 45% for safety.

```yaml
- platform: template
  sensors:
    is_person1_home:
      friendly_name: 'Is Person1 Home?'
      value_template: '{{ state_attr("sensor.person1_home_confidence","mean") | float > 45 }}'
```

The **value_template** could probably be changed to
*states('sensor.person1_home_confidence')*.

At this point we have a sensor that returns true or false if it can see the bluetooth device we are looking for. But it's not actually connected to any HA automations.

In my existing configuration I am using
```yaml
- platform: bluetooth_le_tracker

- platform: bluetooth_tracker
```
Which auto populates the **known_devices** file.
These devices are then used as triggers for my automations. I want to avoid making larges changes. So we are going to make some virtual device_trackers. These will replace the ones created using the provided bluetooth trackers.

In the **devices_tracker** configuration file we will add something like:

```yaml
- platform: mqtt
  source_type: 'bluetooth'
  devices:
    person1: 'location/person1'
```

We are basically saying that we are want an MQTT Topic called location/person1. We will be publishing state to this with some scripts later.

This is where I actually got stuck and it wasn't until I found [this bit of wisdom](https://community.home-assistant.io/t/combining-multiple-device-trackers-into-one-using-mqtt/45324) that things fell into place.

We need to manually add entries to the **known_devices** file.

```yaml
person1:
  hide_if_away: false
  icon:
  mac:
  picture:
  vendor:
  track: true
  name: Test Person
```

 We now have a **device_tracker.person1** which will have its state taken from **MQTT:location/person1**

!!! note
    If you test this state you will get a **source: null**. This will not be set until we first publish to MQTT.

#### Moving on to the scripts

Now we need to start being able to update the **MQTT:location/person1** so that **device_tracker.person1** will have either a **'home'** or **'not_home'** state.

We will edit our script configuration files.

```yaml
'person1_home':
  alias: "Person1 Home"
  sequence:
    - service: mqtt.publish
      data:
        topic: location/person1
        payload: 'home'

'person1_away':
  alias: "Person1 away"
  sequence:
    - service: mqtt.publish
      data:
        topic: location/person1
        payload: 'not_home'

```

These two scripts will update the device_tracker so that we can use their state. We will need an automation so that the state is updated.

But I will add a bonus script here as well. This will trigger a bluetooth rescan. This can be triggered on a restart of HA with an automation.

```yaml
'bt_rescan':
  alias: "Issue BT Rescan"
  sequence:
    - service: mqtt.publish
      data:
        topic: monitor/scan/restart
        payload: ''
```

Add the following configuration to automations.

```yaml
- alias: Set Person home
  initial_state: 'on'
  trigger:
    - platform: state
      entity_id: sensor.is_person1_home
    - platform: homeassistant
      event: start
  condition:
    - condition: state
      entity_id: 'sensor.is_person1_home'
      state: 'True'
  action:
    - service: script.person1_home

- alias: Set Person1 away
  initial_state: 'on'
  trigger:
    - platform: state
      entity_id: sensor.is_person1_home
    - platform: homeassistant
      event: start
  condition:
    - condition: state
      entity_id: 'sensor.is_person1_home'
      state: 'False'
  action:
    - service: script.person1_away
```
This is where we link everything together. We also have the automations trigger when HA starts up. So we get some initial state.

I personally also opted to have a BT scan triggered when ever HA restarts.

I added this configuration to automations.
```yaml
alias: "HA Started"
initial_state: 'on'
trigger:
  platform: homeassistant
  event: start
action:
  - service: script.bt_rescan
```

The final step is the replace all the previous device_tracker references with the new manaully created ones listed in **known_devices.yaml**

### Final Thoughts

This is not yet an Ideal setup. I am still working on it. But if you look at the blog links below you might get some more ideas. I am still reading through them and improving things.


As I stated at the start. This is mostly for me so that I have some documentation for myself.

But I hope others might find it useful. Since I had to work through it and piece it together.

Thanks to those who posted the work online. It was invaluable. The main part I found missing was the **known_devices.yaml**


<hr/>

### References

- [Bluetooth Presence Detection for Home Automation – The Level1 Way](https://forum.level1techs.com/t/bluetooth-presence-detection-for-home-automation-the-level1-way/148516)

- [[monitor] Reliable, Multi-User, Distributed Bluetooth Occupancy/Presence Detection](https://community.home-assistant.io/t/monitor-reliable-multi-user-distributed-bluetooth-occupancy-presence-detection/68505)

#### Links used from [Tinkerer](https://blog.ceard.tech)

The config is far beyond what I need. But it's a great resource.

- [Presence detection - are we nearly there yet?](https://blog.ceard.tech/2019/03/presence-detection-are-we-nearly-there.html)
- [Presence detection, the final countdown?](https://blog.ceard.tech/2019/10/presence-detection-final-countdown.html)
- [Presence detection updated](https://blog.ceard.tech/2018/09/a-while-back-i-covered-how-i-was-doing.html)
- [GitHub Repo](https://github.com/DubhAd/Home-AssistantConfig)

#### Some missing Magic
- [The missing magic to make MQTT State usable as a device_tracker](https://community.home-assistant.io/t/combining-multiple-device-trackers-into-one-using-mqtt/45324)

### Software
- [Monitor](https://github.com/andrewjfreyer/monitor)
