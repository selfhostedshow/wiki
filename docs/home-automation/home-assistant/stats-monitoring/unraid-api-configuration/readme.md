# UnRAID-API Configuration - Home Assistant

## Setup MQTT on Home Assistant
Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to Supervisor -> Add-on Store.
2. Find the "Mosquitto broker" add-on and click it.
3. Click on the "INSTALL" button.

### How to use
The add-on has a couple of options available. To get the add-on running:

Start the add-on.
1. Have some patience and wait a couple of minutes.
2. Check the add-on log output to see the result.
3. Create a new user for MQTT via the Configuration -> Users (manage users). Note: This name cannot be `homeassistant` or `addon`, those are reserved usernames.

To use the Mosquitto as a broker, go to the integration page and install the configuration with one click:

1. Navigate in your Home Assistant frontend to Configuration -> Integrations.
2. MQTT should appear as a discovered integration at the top of the page
3. Select it and check the box to enable MQTT discovery if desired, and hit submit.

If you have old MQTT settings available, remove this old integration and restart Home Assistant to see the new one.

These need to be configured and working before you proceed to configure the UnRAID-API
 - Mosquitto broker
 - MQTT Integration

**_When setting up the MQTT integration, ensure that you tick the box to enable discovery._**

To test your MQTT server is functioning correctly you can connect to the MQTT instance, replacing `'username'` and `'password'` with your MQTT credentials. 

```
mosquitto_sub -h 192.168.1.201 -u 'username' -P 'password' -t "#"
```

## UNRAID-API Container Configuration

Install the [UnRAID-API](https://github.com/ElectricBrainUK/UnraidAPI) on your UnRAID server, this can also be installed from the UnRAID App Store.

![unraid-api-container]('/docs/home-automation/home-assistant/stats-monitoring/unraid-api-configuration/images/unraid-api.png')

When you get to the configuration screen for the container following keys need to be added to the default container configuration

|Name|Type|Default|Description|
|---|---|---|---|
|MQTTRefreshRate|number|5|Time in seconds to poll for updates|
|MQTTCacheTime|number|1|Time in minutes after which all entities will be updated in MQTT|

As an example this is the value for key 7, you will need to replicate it for key 8 found in the table above. 

![Container Key]'/docs/home-automation/home-assistant/stats-monitoring/unraid-api-configuration/images/key-7.png')

You will also need to configure your MQTT Broker, replacing the fields marked in Yellow.

![Container MQTT]('/docs/home-automation/home-assistant/stats-monitoring/unraid-api-configuration/images/container-configuration.png')

### Starting The Container
When you start the container for the first time you must browse to the login screen of the UnRAID-API Web-UI and login with your UnRAID credentials. If this step is missed the API will not work. 

![Web-UI]('/docs/home-automation/home-assistant/stats-monitoring/unraid-api-configuration/images/web-ui.png')

### Check Home Assistant
Once the UnRAID-API container is up and running check the mqtt integration, you should now have some UnRAID entities. If not please reboot your Home Assistant instance, once your Home Assistant instance has rebooted wait at least 3 minutes for entities to appear in the integration. 

![mqtt-integration]('/dev/docs/home-automation/home-assistant/stats-monitoring/unraid-api-configuration/images/mqtt.png')

### Setting Up Sensors
The following sensors can be configured in Home Assistant to view the following information. Ensure that you change `unraid_server_name` for the `binary_sensor` of your entity in `Home Assistant`

#### arrayStatus

```YAML
sensor:
  - platform: template
    sensors:
      unraid_array_status:
        friendly_name: UnRAID Array Status
        value_template: >
          {{state_attr("binary_sensor.unraid_server_name", "arrayStatus")}}
```

#### arrayProtection


```YAML
sensor:
  - platform: template
    sensors:
      unraid_array_protection:
        friendly_name: UnRAID Array Protection
        value_template: >
          {{state_attr("binary_sensor.unraid_server_name", "arrayProtection")}}
```
#### diskSpace
 
```YAML
sensor:
  - platform: template
    sensors:
      unraid_array_space:
        friendly_name: UnRAID Array Space
        value_template: >
          {% set state = state_attr("switch.unraid_server_name_array", "diskSpace") %} 
          {{ Offline if state == None else state | regex_findall_index(".*\((\d+.?\d+) %\)") | float }}
        unit_of_measurement: '%'
```
