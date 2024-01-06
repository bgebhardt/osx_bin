# Bluetooth Scripting notes

Use blueutil for managing bluetooth
Blueutil, a command-line utility for macOS that lets us turn Bluetooth on and off with one command!

[toy/blueutil: CLI for bluetooth on OSX: power, discoverable state, list, inquire devices, connect, info, …](https://github.com/toy/blueutil)

Install via brew

```brew install blueutil```

## Commands and Scripts

The -p or --power flag is a switch for turning Bluetooth on and off:

```
blueutil --power 1 # turn on
blueutil --power 0 # turn off
```
Key options

   -p, --power               output power state as 1 or 0
    -p, --power STATE         set power state
    -d, --discoverable        output discoverable state as 1 or 0
    -d, --discoverable STATE  set discoverable state

Managing favorites

        --favourites, --favorites
                              list favourite devices
        --inquiry [T]         inquiry devices in range, 10 seconds duration by default excluding time for name updates
        --paired              list paired devices
        --recent [N]          list recently used devices, 10 by default, 0 to list all
        --connected           list connected devices

        --info ID             show information about device
        --is-connected ID     connected state of device as 1 or 0
        --connect ID          create a connection to device
        --disconnect ID       close the connection to device
        --pair ID [PIN]       pair with device, optional PIN of up to 16 characters will be used instead of interactive input if requested in specific pair mode
        --unpair ID           EXPERIMENTAL unpair the device
        --add-favourite ID, --add-favorite ID
                              add to favourites
        --remove-favourite ID, --remove-favorite ID
                              remove from favourites

        --format FORMAT       change output format of info and all listing commands

        --wait-connect ID [TIMEOUT]
                              EXPERIMENTAL wait for device to connect
        --wait-disconnect ID [TIMEOUT]
                              EXPERIMENTAL wait for device to disconnect
        --wait-rssi ID OP VALUE [PERIOD [TIMEOUT]]
                              EXPERIMENTAL wait for device RSSI value which is 0 for golden range, -129 if it cannot be read (e.g. device is disconnected)


# Applescript Approaches

The approach is to use UI scripting to change it in the preferences panel. Not ideal as the UI has changed a lot in recent MacOS releases.

This article has a few different versions for various os versions.
[macos - Toggle Bluetooth AppleScript not Working in Yosemite - Ask Different](https://apple.stackexchange.com/questions/152333/toggle-bluetooth-applescript-not-working-in-yosemite)

[macos - AppleScript to toggle Bluetooth - Stack Overflow](https://stackoverflow.com/questions/19752438/applescript-to-toggle-bluetooth)

Here's an old post on connecting to devices which could be useful one day.
[mac - Applescript to connect to bluetooth device - Super User](https://superuser.com/questions/468556/applescript-to-connect-to-bluetooth-device)