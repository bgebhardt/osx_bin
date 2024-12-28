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
install_app() {
    local url=$1
    local app_name=$2

    echo "Downloading $app_name..."

    local download_dir="$HOME/Downloads"

    curl -L -o $download_dir/$app_name $(basename $url)

    if [[ $url == *.zip ]]; then
        echo "Unzipping $app_name..."
        unzip -q $download_dir/$app_name.zip -d $download_dir/$app_name

        echo "Installing $app_name..."
        cp -r $download_dir/$app_name/*.app /Applications/
    else
        echo "Mounting $app_name.dmg..."
        hdiutil attach $download_dir/$app_name.dmg -nobrowse -quiet

        echo "Installing $app_name..."
        cp -r /Volumes/$app_name/*.app /Applications/

        echo "Cleaning up..."
        hdiutil detach /Volumes/$app_name -quiet
    fi

    #echo "Cleaning up..."
    #rm -rf $download_dir/$app_name*

    echo "$app_name installed successfully!"
}

# List of apps to install
apps=(
    # "https://freefilesync.org/download.php FreeFileSync" # go to this link for latest version
    "https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip" FreeFileSync # hardcoded version for now
    "https://github.com/alyssaxuu/later/raw/master/Later.dmg Later"
    "https://www.drbuho.com/download/buhocleaner.dmg BuhoCleaner"
    "https://wifiradar.app/download WiFiRadar"
    "https://jsonwizard.app/download JSONWizard"
    "https://seense.com/the_clock/updateapp/the_clock.zip TheClock"
    "https://dl.devant.io/v1/3c53887f-427a-4af7-9144-ee16178c62f4/21049/RapidWeaver.zip RapidWeaver"
    
    # https://skylum.com/account/my-software
    "https://skylum.com/download/luminar-neo-m1-paid" LuminarNeo

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
    "https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip" FreeFileSync # hardcoded version for 
    "https://jsonwizard.app/download JSONWizard"
)

# Install each app
for app in "${apps[@]}"; do
    IFS=' ' read -r url name <<< "$app"
    install_app $url $name
done

echo "All apps installed successfully!"