### Message brokers

To simplify and organize communication between devices, it is sometimes useful to set up a message broker.

The message broker organizes messages into topics, and holds messages in a queue for delivery if the recipient is offline or sleeping.

By acting as a central message-storage and message-routing service, a message broker can:
  - simplify monitoring (e.g. having Prometheus montitor message counts on the broker to visualize traffic) 
  - simplify debugging of event triggers by reading all messages published on a topic

Some message brokers support multi-node high-availability modes that offer durability or availablity despite single-node failures.

... But mostly it's just cool and (if setup as a standalone system) means you now have a message broker you can use for home automation or experimentation.

### MQTT 

MQTT is a protocol for passing messages between multiple devices. Because it is lightweight, it has been adopted by a few IoT firmware ecosystems like ESPHome and Tasmota.

Some message brokers speak the MQTT protocol.

A message broker is not required for Home Assistant, but a message broker service is required to coordinate communication between MQTT clients.
