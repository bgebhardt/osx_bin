#!/bin/bash

# This script installs a list of apps from URLs.
# The following apps you'll have to get and install via there web installer

# * [FreeFileSync: Open Source File Synchronization & Backup Software](https://freefilesync.org/)
#   * [Download the Latest Version - FreeFileSync](https://freefilesync.org/download.php)
# * [Marked 2 - Smarter tools for smarter writers](https://marked2app.com/) - I bought from developer instead of Mac App Store
# * [alyssaxuu/later: Save all your Mac apps for later with one click 🖱️](https://github.com/alyssaxuu/later) - free app to save and restore open windows. Awesome!
# * [BuhoCleaner: The Best Mac Cleaner Optimized for M1/M2 Macs](https://www.drbuho.com/)
# * [Snail](https://snail.murusfirewall.com/) traffic shaping for MacOS
# * [WiFiRadar Pro | Wireless monitoring on steroids](https://wifiradar.app/)
# * [JSON Wizard | JSON, the easy way. For Mac.](https://jsonwizard.app/)
# * [Premium Fonts for Mac and Windows | MacAppware](https://macappware.com/software/mac-fonts/)
# * [Mac Font Manager Deluxe | MacAppware](https://macappware.com/software/mac-font-manager-deluxe/)
# * Clock - no cask; same software maker [seense | The Clock for macOS](https://seense.com/the_clock/)
# * Quick expose - no cask; same software maker [Quick Exposé: A New Way to Use Mission Control and App Exposé on macOS • MacPlus Software](https://noteifyapp.com/quick-expose/) 
# * Rapidweaver - download 9.1.1 from [RapidWeaver Release Notes](https://www.realmacsoftware.com/rapidweaver/releasenotes/) or [direct link](https://dl.devant.io/v1/3c53887f-427a-4af7-9144-ee16178c62f4/21049/RapidWeaver.zip)

# Function to download and install an app from a URL, detecting if it is a zip file
download_app() {
    local url=$1
    local app_name=$2
    local downloadName="$(basename "$url")"
    local download_dir="$HOME/Downloads"
    local localFilePath="$download_dir/$downloadName"

    echo "Downloading $app_name..."
    echo "  from $url"
    echo "  to $localFilePath"

    #curl -L -o ~/Downloads/FreeFileSync_13.9_macOS.zip https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip
    # curl -L -o "$localFilePath" "$url"
    open "$url" # opens the URL in the default browser and downloads the file to Downloads. Very fragile though.
}

# Function to download and install an app from a URL, detecting if it is a zip file
install_app() {
    local url=$1
    local app_name=$2
    local downloadName="$(basename "$url")"
    local download_dir="$HOME/Downloads"
    local localFilePath="$download_dir/$downloadName"

        if [[ $url == *.zip ]]; then
        echo "Unzipping $app_name..."
        #unzip -q "$localFilePath" -d "$download_dir/$app_name"
        unzip "$localFilePath"

        echo "Installing $app_name..."
        # copy app to /Applications or run the pkg installer
        #cp -r $download_dir/$app_name/*.app /Applications/
    else
        echo "Mounting $app_name.dmg..."
        hdiutil attach "$localFilePath" #-quiet

        echo "Installing $app_name..."
        #cp -r /Volumes/$app_name/*.app /Applications/

        echo "Cleaning up..."
        hdiutil detach "/Volumes/$app_name" #-quiet
    fi

    #echo "Cleaning up..."
    #rm -rf $download_dir/$app_name*

    echo "$app_name installed successfully!"
}

# List of apps to install
apps=(
    # "https://freefilesync.org/download.php FreeFileSync" # go to this link for latest version
    # hardcoded version for now
    "https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip FreeFileSync"
    "https://github.com/alyssaxuu/later/raw/master/Later.dmg Later"
    "https://www.drbuho.com/download/buhocleaner.dmg BuhoCleaner"
    "https://wifiradar.app/download WiFiRadar"
    "https://jsonwizard.app/download JSONWizard"
    "https://seense.com/the_clock/updateapp/the_clock.zip TheClock"
    "https://dl.devant.io/v1/3c53887f-427a-4af7-9144-ee16178c62f4/21049/RapidWeaver.zip RapidWeaver"
        
    # https://skylum.com/account/my-software
    "https://skylum.com/download/luminar-neo-m1-paid" LuminarNeo
    
    # Drive Thru RPG site https://legacy.drivethrurpg.com/library_client.php
    "https://dtrpg-library-app.s3.us-east-2.amazonaws.com/DriveThruRPG_3.4.6.dmg" DriveThruRPG

    # apps I no longer install
    #"https://noteifyapp.com/download/QuickExpose.zip QuickExpose"
    #"https://marked2app.com/download/ Marked2"
    #"https://github.com/TheMurusTeam/Snail/releases/download/v3.0/snail-3.0.zip Snail"
    #"https://macappware.com/software/mac-fonts/download MacFonts" not working
    #"https://macappware.com/software/mac-font-manager-deluxe/download MacFontManagerDeluxe" not working
)

# two apps to test with
test_apps=(
    # "https://freefilesync.org/download.php FreeFileSync" # go to this link for latest version
    # hardcoded version for now
    "https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip FreeFileSync"
    "https://jsonwizard.app/download JSONWizard"
)

# Install each app
#for app in "${test_apps[@]}"; do
for app in "${apps[@]}"; do
    IFS=' ' read -r url name <<< "$app"
    download_app $url $name
    #install_app $url $name
done

echo "All apps installed successfully!"