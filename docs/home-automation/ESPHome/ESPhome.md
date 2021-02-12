# Tasmota

Free your devices from the cloud.
## Introduction
Tasmota is an alternative firmware for the ESP8266.
Installation is done in a couple different ways;

* OTA (over the air).
* flashing over serial.

## Useful Links

* [Blakadder template repository](https://templates.blakadder.com/index.html)

## Installation
The main ways of installing Tasmota on a device are:

* OTA (over the air).
* Flashing over serial.

### OTA (Over the air)
OTA is the quickest, if your device supports it. OTA requires a device that has a firmware update mechanism with a "vulnerabulity", so a spoofing update network can upload tasmota, instead of the manufacturers own firmware.

For most users this means that you would look for a device that is supported by a tool already written to exploit the firmware update mechanism. Such as [Tuya-Convert](#tuya-convert), or [SonOTA](#sonota).

#### Tuya-Convert 
The [Tuya-Convert tool](https://github.com/ct-Open-Source/tuya-convert) allows many devices labled "Tuya - Smart Life".
![Tuya Smart Life, logo, and title.](images/Tuya_Smart_Life.jpg)

#### SonOTA
The [SonOTA tool](https://github.com/mirko/SonOTA) Supports some of the devices released by [ITEAD](https://www.itead.cc/smart-home.html), under the Sonoff brand. 

### Serial Flash
Well documented in the [Tasmota Documentation](https://tasmota.github.io/docs/#/installation/Prerequisites). 
