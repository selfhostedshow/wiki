# ADB - Android Debug Bridge

Requirements: 

 * [ADB Addon](https://github.com/hassio-addons/addon-adb/)

This guide walks you though how to configure Android Debug Bridge for controlling Android TV through [Home Assistant](https://www.home-assistant.io/).

Initially you will need to install the add-on through the Home Assistant Supervisor Add-on Store. Once the Add-on is installed you will need to configure your devices as per the example below. 

 ```Config
    devices:
    - 1.2.3.4
    - 4.3.2.1
    reconnect_timeout: 30
    log_level: info
    keys_path: /config/.androidkeys
```

**I would recommend you create a path in you config folder for the `.androidkeys` to be stored as this will help you in the future should you ever need to move your instance.**

Once the configuration is in place start the add-on and check the logs for any errors. 

## Configuring your Android TV 

In this example I will be using the Shield TV to enable Network debugging. 

1. Enable developer options - On you Android TV, go to `Settings > About SHIELD`, scroll to the bottom and tap Build Number several times.
2. Enable network debugging - On you device in `Settings > Developer Options` enable Network Debugging.
3. Add the following configuration to your home assistant configuration.

```YAML
media_player:

  - platform: androidtv
    host: 1.2.3.4
    name: "Living Room Super Shield"
    adb_server_ip: 127.0.0.1
    adb_server_port: 5037
```
4. Restart Home Assistant.
5. Restart `ADB` in Home Assistant.
6. Allow `Home Assistant` to access to your device, remember the check the box to always remember this device.


## Connect to the container running ADB

If you are using Home Assistant backed Ubuntu or other debian based OS this next step is done in Bash, if you are running the enclosed Home Assistant OS install the [Terminal & SSH plugin](https://github.com/home-assistant/hassio-addons/tree/master/ssh).

Open you command line `Shell` to bash into the container.

    docker exec -it addon_a0d7b954_adb /bin/bash

### List all installed Packages and Activities

This section explains how you can query `ADB` for applications running on you `Android TV`

1. Connect to ADB Shell.

        adb -s 1.2.3.4:5555 shell

2. Type in the following command to list all packages and their associated files. 

        pm list packages

3. To filter the output based on the package name.

        pm list packages | grep com.amazon.amazonvideo.livingroom.nvidia

4. To find all activities published by a package, use the following command & replace com.symbol.wfc.voice by the name of the package to process.

        dumpsys package | grep -Eo "^[[:space:]]+[0-9a-f]+[[:space:]]+com.nvidia.bbciplayer.launch/[^[:space:]]+" | grep -oE "[^[:space:]]+$"


### List installed Packages and Activities

        pm list packages | sed -e "s/package://" | while read x; do cmd package resolve-activity --brief $x | tail -n 1 | grep -v "No activity found"; done 

</br> Output

    com.plexapp.android/com.plexapp.plex.activities.SplashActivity
    android/com.android.internal.app.ResolverActivity
    com.nvidia.tegrazone3/com.nvidia.tegrazone.MainActivity
    com.android.documentsui/.LauncherActivity
    com.nest.android/com.obsidian.v4.activity.LoginActivity
    com.silicondust.view/.App
    com.plexapp.mediaserver.smb/com.plexapp.mediaserver.ui.main.MainActivity
    com.android.vending/com.google.android.finsky.tvmainactivity.TvMainActivity
    nextapp.fx/.ui.ExplorerActivity
    com.onemainstream.skynews.android/.common.splash.SplashActivity
    com.google.android.tv/com.android.tv.TvActivity
    com.nvidia.inputviewer/.AccessorySelectionActivity
    com.android.gallery3d/.app.GalleryActivity
    com.nvidia.ota/.ui.LauncherActivity
    com.ubnt.unifi.protect/com.ubnt.sections.splash.SplashActivity
    com.google.android.youtube.tv/com.google.android.apps.youtube.tv.activity.ShellActivity
    com.google.android.tv.remote.service/.settings.SettingsActivity
    com.valvesoftware.steamlink/.SteamShellActivity
    com.netflix.ninja/.MainActivity


Make a list of your applications and the options available, you'll need this later, I have exported a few Apps below as examples.


## Discovered App Activities


#### BBC iPlayer

    com.nvidia.bbciplayer/.MainPlayerActivity
    com.nvidia.bbciplayer/.DeepLinkActivity
    com.nvidia.bbciplayer/.MainNewsActivity
    com.nvidia.bbciplayer/.MainPlayerActivity
    com.nvidia.bbciplayer/.BaseWebViewActivity
    com.nvidia.bbciplayer/.MainPlayerActivity
    com.nvidia.bbciplayer/.CatalTestActivity
    com.nvidia.bbciplayer/.MainSportActivity
    com.nvidia.bbciplayer/.Channels.InitializeChannelsReceiver
    com.nvidia.bbciplayer/.Channels.InitializeChannelsReceiver
    com.nvidia.bbciplayer/.Channels.InitializeChannelsReceiver
    com.nvidia.bbciplayer/.Channels.InitializeChannelsReceiver
    com.nvidia.bbciplayer/.Channels.InitializeChannelsReceiver


#### BBC News

    com.nvidia.bbciplayer.launch/com.nvidia.bbciplayer.LaunchNewsActivity

#### BBC Sport

    com.nvidia.bbciplayer.launchsport/com.nvidia.bbciplayer.LaunchSportActivity

#### HD Home Run    
    
    com.silicondust.view/.App

#### GeForce Now

    com.nvidia.tegrazone3/com.nvidia.tegrazone.MainActivity

#### ITV Player

    air.ITVMobilePlayer/com.itv.tenft.itvhub.RecommendationActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.MainActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.WatchNextActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.MainActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.GlobalSearchActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.MainActivity
    air.ITVMobilePlayer/com.itv.tenft.itvhub.receiver.UpdateCatalogueReceiver
    air.ITVMobilePlayer/com.itv.tenft.itvhub.receiver.UpdateCatalogueReceiver

#### Leanback Launcher

    com.google.android.tvlauncher/.MainActivity

    com.google.android.tvlauncher/.appsview.RemoveAppLinkActivity
    com.google.android.tvlauncher/.settings.OpenSourceActivity
    com.google.android.tvlauncher/.appsview.AddAppLinkActivity
    com.google.android.tvlauncher/.inputs.InputsPanelActivity
    com.google.android.tvlauncher/.appsview.AppsViewActivity
    com.google.android.tvlauncher/.settings.HomeScreenSettingsActivity
    com.google.android.tvlauncher/.settings.HomeScreenSettingsActivity
    com.google.android.tvlauncher/.notifications.NotificationsSidePanelActivity
    com.google.android.tvlauncher/.appsview.data.MarketUpdateReceiver

#### Nest
    com.nest.android/net.openid.appauth.RedirectUriReceiverActivity
    com.nest.android/com.nestlabs.android.framework.deeplink.DeepLinkRoutingActivity
    com.nest.android/com.obsidian.v4.activity.LoginActivity
    com.nest.android/com.nestlabs.android.framework.deeplink.DeepLinkRoutingActivity
    com.nest.android/com.obsidian.v4.activity.LoginActivity
    com.nest.android/com.obsidian.v4.tv.home.TvHomeActivity
    com.nest.android/com.obsidian.v4.goose.RegisterGeofencesWithOSBroadcastReceiver
    com.nest.android/com.obsidian.v4.goose.healthcheck.GeofenceHealthChangeBroadcastReceiver
    com.nest.android/com.obsidian.v4.goose.reporting.ReportGeofenceTransitionBroadcastReceiver
    com.nest.android/com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver
    com.nest.android/com.obsidian.v4.goose.healthcheck.GeofenceHealthChangeBroadcastReceiver
    com.nest.android/com.nestlabs.android.notificationdisplay.UpdateNotificationChannelsBroadcastReceiver
    com.nest.android/com.google.firebase.iid.FirebaseInstanceIdReceiver
    com.nest.android/com.nestlabs.android.notificationdisplay.UpdateNotificationChannelsBroadcastReceiver
    com.nest.android/com.obsidian.v4.goose.RegisterGeofencesWithOSBroadcastReceiver
    com.nest.android/com.obsidian.v4.goose.RegisterGeofencesWithOSBroadcastReceiver
    com.nest.android/com.nestlabs.android.notificationdisplay.UpdateNotificationChannelsBroadcastReceiver
    com.nest.android/com.obsidian.v4.goose.RegisterGeofencesWithOSBroadcastReceiver
    com.nest.android/com.google.firebase.messaging.FirebaseMessagingService
    com.nest.android/com.obsidian.v4.gcm.NestFirebaseMessagingService

#### Netflix

    com.netflix.ninja/.MainActivity

#### Plex Media Server

    com.plexapp.android/com.plexapp.plex.activities.SplashActivity    

#### Prime Video

    com.amazon.amazonvideo.livingroom/com.amazon.ignition.IgnitionActivity
    com.amazon.amazonvideo.livingroom/com.amazon.ignition.receiver.RunOnInstallReceiver
    com.amazon.amazonvideo.livingroom/com.amazon.ignition.receiver.LocaleChangeReceiver
    com.amazon.amazonvideo.livingroom/com.amazon.ignition.receiver.TimeChangedReceiver
    com.amazon.amazonvideo.livingroom/com.amazon.ignition.receiver.BootUpReceiver
    com.amazon.amazonvideo.livingroom/com.amazon.ignition.receiver.AppUpdateReceiver

    com.amazon.amazonvideo.livingroom.nvidia/com.amazon.amazonvideo.livingroom.migrator.FileMigrationService

#### Sky News

    com.onemainstream.skynews.android/.common.splash.SplashActivity

#### Steam

    com.valvesoftware.steamlink/.SteamShellActivity

#### UniFI Protect

    com.ubnt.unifi.protect/com.ubnt.sections.splash.SplashActivity

#### Windscribe VPN

    com.windscribe.vpn/.LaunchVPN
    com.windscribe.vpn/.splash.SplashActivity
    com.windscribe.vpn/.bootreceiver.WindscribeBootReceiver
    com.windscribe.vpn/.bootreceiver.WindscribeBootReceiver
    com.windscribe.vpn/com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver
    com.windscribe.vpn/com.google.firebase.iid.FirebaseInstanceIdReceiver
    com.windscribe.vpn/.bootreceiver.WindscribeBootReceiver
    com.windscribe.vpn/de.blinkt.openvpn.core.OpenVPNService
    com.windscribe.vpn/.firebasecloud.WindscribeCloudMessaging
    com.windscribe.vpn/com.google.firebase.messaging.FirebaseMessagingService

#### Youtube

    com.google.android.youtube.tv/com.google.android.apps.youtube.tv.activity.ShellActivity




### Configuration in Home Assistant. 

Create a table of values for your `Android TV` apps using the confguration below, please change the `apps` to meet your configuration.

```YAML
media_player:

  - platform: androidtv
    host: !secret shield_shield_tv_ip
    name: "shield Shield"
    adb_server_ip: 127.0.0.1
    adb_server_port: 5037
    apps:
      "com.google.android.tvlauncher": "Home"
      "com.netflix.ninja": "Netflix"
      "com.google.android.youtube.tv": "Youtube"
      "com.google.android.tv": "Live Channels"
      "com.amazon.amazonvideo.livingroom": "Amazon Video"
      "com.plexapp.android": "Plex"
      "com.nvidia.bbciplayer": "iPlayer"
      "com.nvidia.bbciplayer.launch": "BBC News"
      "com.silicondust.view": "HD HomeRun"
```

### Create a script 

To launch Android TV apps from home Assistant you need to create a script. I have created some examples below. 


```YAML
script:

## Leanback Launcher
  adb_open_shield_leanback:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: HOME

## Plex
  adb_open_shield_plex:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "monkey -p com.plexapp.android -c android.intent.category.LAUNCHER 1"

## Netflix
  adb_open_shield_netflix:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "am start -a android.intent.action.VIEW -d -n com.netflix.ninja/.MainActivity"

## Youtube
  adb_open_shield_youtube:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "am start -a android.intent.action.VIEW -d -n com.google.android.youtube.tv/com.google.android.apps.youtube.tv.activity.ShellActivity"

## Amazon Video
  adb_open_shield_amazon:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "am start -a android.intent.action.VIEW -d -n com.amazon.amazonvideo.livingroom/com.amazon.ignition.IgnitionActivity"

## iPlayer
  adb_open_shield_iplayer:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command:  "am start -a android.intent.action.VIEW -d -n com.nvidia.bbciplayer/.MainPlayerActivity"

## BBC News
  adb_open_shield_bbc_news:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "am start -a android.intent.action.VIEW -d -n com.nvidia.bbciplayer.launch/com.nvidia.bbciplayer.LaunchNewsActivity"

## HD Homerun
  adb_open_shield_hd_hr:
    sequence:
      - service: androidtv.adb_command
        data:
          entity_id: media_player.shield_shield_adb
          command: "am start -a android.intent.action.VIEW -d -n com.silicondust.view/.App"
```

Further working examples can be found on this [GitHub](https://github.com/noodlemctwoodle/homeassistant).